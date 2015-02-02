# seareches for list of companies in a file
# file data:  company name, street, city, state, zip
# search results: array of companies
# company: use cases
# 1. {found: false}
# 2. {found: true, employer_id: ID, company_info: text}
#                     --> direct match with input name and zip
# 3. {found: true, employer_id: ID, company_info: text}
#                      --> searched google info to Employer match
# 4. {found: true, oc_id: ID, company_info: text from oc}
# 5. {found: true, company_info: text from google_info, google_info: google info hash}
# Add Employer
#   Add from 4 above
#     copy from OC
#     update company to {found: true, employer_id: ID, company_info: text}
#   Add from 5 above
#     create from google_info
#     update company to {found: true, employer_id: ID, company_info: text}
class CompanyListFinder
  HEADER_FIELDS = %w(company zip)
  attr_reader :error, :process_id

  def initialize(params, user)
    @account_id        = user.account.id
    @count_success     = 0
    @count_fails       = 0
    @original_filename = params[:file].original_filename
    @aws_file_name     = Amazon.store_file(params[:file], 'file_processor')
    generate_process_id(user) if valid_file_type && valid_header
  end

  def errors?
    !@error.blank?
  end

  def process
    open_reader
    Account.current_id = @account_id
    @companies = []
    while (row = @reader.next_row)
      company = process_row(row.with_indifferent_access)
      @companies << company
      company[:found] ? @count_success += 1 : @count_fails += 1
      update_status
    end
    update_complete_status
  end

  def process_row(row)
    zip = clean_zip row[:zip]
    cc  = init_company_hash(row, zip)
    return cc if cc[:error]

    employer = Employer.find_by_name_and_zip(cc[:company], zip)
    return cc.merge(employer_or_oc_found_data(employer, 'EMP')) if employer

    company = Company.new(row[:company], zip)
    company.search
    cc.merge(company_details(company))

  rescue StandardError => error
    cc[:error] = error
    cc
  end

  def employer_or_oc_found_data(company, type)
    data                = { found: true }
    data[:oc_id]        = company.id if type == 'OC'
    data[:employer_id]  = company.id unless type == 'OC'
    data[:company_info] = "#{company.name}<br>#{company.formatted_address}<br>phone:" \
                          "#{company.phone_no}<br>website:#{company.website}"
    data
  end

  def company_details(company)
    return {} unless company.found

    employer = Employer.find(company.employer_id) if company.employer_id
    return employer_or_oc_found_data(employer, 'EMP') if employer
    details      = { found: true, score: company.score }
    info_for_add = company.info_for_add
    oc_id        = info_for_add[:opero_company_id]
    oc = OperoCompany.find(info_for_add[:opero_company_id]) if oc_id
    return details.merge(employer_or_oc_found_data(oc, 'OC')) if oc
    # the final type should be google info
    details[:google_info]  = info_for_add
    details[:company_info] = build_company_info_from_google_info(info_for_add)
    details
  end

  def build_company_info_from_google_info(gi)
    "#{gi[:name]}<br>#{gi[:line1]}<br>#{gi[:city]}, #{gi[:state_code]} #{gi[:zip]}<br>" \
    "phone: #{gi[:phone_no]}<br>website: #{gi[:website]}"
  end

  def clean_zip(zip)
    return nil if zip.blank?
    zip = zip.to_i.to_s if zip.class == Float
    zip = zip.to_s.delete('^0-9')
    zip = zip[0..4]
    zip = '0' * (5 - zip.size) + zip if zip.size < 5
    zip
  end

  def init_company_hash(row, zip)
    info =  { found:      false,
              company:    row[:company].to_s.squish,
              street:     row[:street].to_s.squish,
              city:       row[:city].to_s.squish,
              state_code: row[:state].to_s.squish,
              zip:        zip }

    return { error: 'name is missing' }.merge(info) if info[:company].blank?
    return { error: 'invalid or missing zip' }.merge(info) if zip.blank?

    city = City.where(zip: zip).first
    return { error: "city not found for zip #{zip}" }.merge(info) unless city
    info.merge(city_id: city.id, city: city.name,
               city_state: city.city_state, county: city.county.name)
  end

  def open_reader
    file_path = Amazon.file_url(@aws_file_name).to_s
    @reader = FileReader.new(file_path, @original_filename)
    rescue StandardError => error
      @error = error
  end

  def close_reader
    @reader = nil
  end

  def valid_header
    open_reader
    return false if errors?
    header = @reader.header.map { |c| c.downcase }
    valid = (header & HEADER_FIELDS).size == HEADER_FIELDS.size
    @error = 'Invalid Header Row.' unless valid
    close_reader
    valid
  end

  def valid_file_type
    valid = ['.xls', '.xlsx'].include? File.extname(@original_filename).downcase
    @error = "Invalid file type: #{@original_filename}" unless valid
    valid
  end

  def generate_process_id(user)
    @process_id = user.name.gsub(' ', '').upcase + '-' +
                  user.id.to_s + '-' +
                  Time.now.strftime('%m%d%y%H%M%S')
  end

  def update_status(complete = false)
    status = { status: complete ? 'FINISHED' : 'PROCESSING',
               success_count: @count_success, fail_count: @count_fails,
               file_name: @original_filename }
    write_cache(@process_id + '-STATUS', status)
  end

  def update_complete_status
    update_status(true)
    write_cache(@process_id + '-DATA', @companies)
  end

  def account
    @account ||= Account.find(@account_id)
  end

  def self.status(process_id)
    Rails.cache.read(process_id + '-STATUS')
  end

  def self.companies_data(process_id)
    Rails.cache.read(process_id + '-DATA')
  end

  def self.read_cache(key)
    Rails.cache.read(key)
  end

  def write_cache(key, data, expires_in = 1.hour)
    Rails.cache.write(key, data, expires_in: expires_in)
  end

  def self.cached_companies(process_id)
    return nil unless status(process_id)
    companies_data(process_id)
  end

  def self.create_employer_with_file_data(company, source, sector_ids, user)
    data = { name: company[:company].squish, source: source, sector_ids: sector_ids }
    data[:address_attributes]        = { zip: company[:zip] }
    data[:address_attributes][:city] = company[:city]
    data[:address_attributes][:line1] = company[:street]
    data[:address_attributes][:state] = company[:state_code]

    employer, saved = EmployerFactory.create_employer(user, data)
    error = employer.errors.map { |k, v| "#{k}-#{v}" }.join(';') unless saved

    [employer, error]
  end

  def self.add_employer(params, user)
    process_id = params[:process_id]
    companies  = cached_companies(process_id)
    return nil unless companies

    index      = params[:index].to_i
    company    = companies[index]
    source     = params[:source]
    sector_ids = params[:sector_ids]
    if company[:oc_id]
      employer, _exists, error = EmployerFactory.create_from_opero(company[:oc_id],
                                                                   source, sector_ids)
    elsif company[:google_info]
      employer, _exists, error = EmployerFactory.create_from_gi(company[:google_info],
                                                                source, sector_ids)
    else
      employer, error = create_employer_with_file_data(company, source, sector_ids, user)
    end
    return [employer, error] if error
    company[:employer_id] = employer.id
    companies[index]      = company
    Rails.cache.write(process_id + '-DATA', companies, expires_in: 2.hours)

    [employer, nil]
  end

  # for reading input file - excel data
  class FileReader
    attr_reader :header

    def initialize(file_path, file_name)
      @spreadsheet = open_spreadsheet(file_path, file_name)
      @header = @spreadsheet.row(1).map { |c| c.downcase }
      @next_row = 2
    end

    def next_row
      return nil unless @next_row <= @spreadsheet.last_row
      row = Hash[[@header, @spreadsheet.row(@next_row)].transpose]
      @next_row += 1
      row
    end

    def open_spreadsheet(file_path, file_name)
      ext = File.extname(file_name).downcase
      return Roo::Excel.new(file_path, nil, :ignore) if ext == '.xls'
      return Roo::Excelx.new(file_path, packed: nil,
                                        file_warning: :ignore)  if ext == '.xlsx'
    end
  end
end
