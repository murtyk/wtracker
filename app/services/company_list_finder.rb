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
  attr_reader :error, :process_id, :user

  def initialize(params, user)
    @user              = user
    @account_id        = user.account.id
    @count_success     = 0
    @count_fails       = 0
    @companies         = []
    @original_filename = params[:file].original_filename
    @aws_file_name     = Amazon.store_file(params[:file], 'file_processor')
    generate_process_id(user) if valid_file_type && valid_header
  end

  def errors?
    @error
  end

  def process
    open_reader
    Account.current_id = @account_id
    while (row = @reader.next_row)
      company = process_row(row)
      @companies << company
      update_counts(company)
      update_status
    end
    update_complete_status
  end

  def update_counts(company)
    @count_success += 1 if company[:found]
    @count_fails += 1 unless company[:found]
  end

  def process_row(row)
    zip = clean_zip row[:zip]
    cc  = init_company_hash(row, zip)
    return cc if cc[:error]

    employer = Employer.find_by_name_and_zip(cc[:company], zip)
    return cc.merge(employer_or_oc_found_data(employer, 'EMP')) if employer

    cc.merge(search_company_details(row, zip))

  rescue StandardError => error
    cc[:error] = error.to_s
    cc
  end

  def employer_or_oc_found_data(company, type)
    data                = { found: true }
    data[:oc_id]        = company.id if type == 'OC'
    data[:employer_id]  = company.id unless type == 'OC'

    data[:company_info] = [company.name,
                           company.formatted_address,
                           'phone:' + company.phone_no,
                           'website:' + company.website].join('<br>')
    data
  end

  def search_company_details(row, zip)
    company = Company.new(row[:company], zip, user)
    company.search
    company.found ? company_details(company) : {}
  end

  def company_details(company)
    employer = Employer.find(company.employer_id) if company.employer_id
    return employer_or_oc_found_data(employer, 'EMP') if employer

    details      = { found: true, score: company.score }
    info_for_add = company.info_for_add

    oc_id        = info_for_add[:opero_company_id]
    oc = OperoCompany.find(oc_id) if oc_id
    return details.merge(employer_or_oc_found_data(oc, 'OC')) if oc

    # the final type should be google info
    details[:google_info]  = info_for_add
    details[:company_info] = build_company_info_from_google_info(info_for_add)
    details
  end

  def build_company_info_from_google_info(gi)
    [gi[:name], gi[:line1], gi[:city], gi[:state_code], gi[:zip],
     'phone:' + gi[:phone_no], 'website:' + gi[:website]].join('<br>')
  end

  def clean_zip(zip)
    return nil if zip.blank?
    zip = zip.to_i.to_s if zip.is_a? Float
    zip = zip.to_s.delete('^0-9')
    zip = zip[0..4]
    zip = '0' * (5 - zip.size) + zip if zip.size < 5
    zip
  end

  def init_company_hash(row, zip)
    info =  build_info_hash(row, zip)

    return { error: 'name is missing' }.merge(info) if info[:company].blank?
    return { error: 'invalid or missing zip' }.merge(info) if zip.blank?

    city = City.where(zip: zip).first
    return { error: "city not found for zip #{zip}" }.merge(info) unless city
    info.merge(city_id: city.id, city: city.name,
               city_state: city.city_state, county: city.county_name)
  end

  def build_info_hash(row, zip)
    { found:      false,
      company:    row[:company].to_s.squish,
      street:     row[:street].to_s.squish,
      city:       row[:city].to_s.squish,
      state_code: row[:state].to_s.squish,
      zip:        zip }
  end

  def open_reader
    file_path = Amazon.file_url(@aws_file_name).to_s
    @reader = ImportFileReader.new(file_path, @original_filename)
    rescue StandardError => error
      @error = error
  end

  def close_reader
    @reader = nil
  end

  def valid_header
    open_reader
    return false if errors?
    header = @reader.header
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

  def self.write_cache(key, data, expires_in = 1.hour)
    Rails.cache.write(key, data, expires_in: expires_in)
  end

  def self.cached_companies(process_id)
    return nil unless status(process_id)
    companies_data(process_id)
  end

  def self.create_employer_with_file_data(company, sector_ids, user)
    data = { name: company[:company].squish, sector_ids: sector_ids }
    data[:address_attributes]        = extract_address_attr(company)

    employer, saved = EmployerFactory.create_employer(user, data)
    error = employer.errors.map { |k, v| "#{k}-#{v}" }.join(';') unless saved

    [employer, false, error]
  end

  def self.extract_address_attr(company)
    { zip: company[:zip],
      city: company[:city],
      line1: company[:street],
      state: company[:state_code] }
  end

  def self.add_employer(params, user)
    process_id = params[:process_id]
    companies  = cached_companies(process_id)
    return unless companies

    index      = params[:index].to_i
    company    = companies[index]

    employer, _exists, error = add_employer_from_data(company, user, params)

    return [employer, error] if error
    company[:employer_id] = employer.id
    companies[index]      = company
    write_cache(process_id + '-DATA', companies, 2.hours)

    employer
  end

  def self.add_employer_from_data(company, user, params)
    sector_ids = params[:sector_ids]
    source_id  = user.employer_source_id
    if company[:oc_id]
      EmployerFactory.create_from_opero(company[:oc_id], source_id, sector_ids)
    elsif company[:google_info]
      EmployerFactory.create_from_gi(company[:google_info], source_id, sector_ids)
    else
      create_employer_with_file_data(company, sector_ids, user)
    end
  end
end
