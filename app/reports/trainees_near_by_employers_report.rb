# frozen_string_literal: true

# contains data for employers near trainees report
class TraineesNearByEmployersReport < Report
  attr_accessor :distance

  alias_attribute(:radius, :distance)

  attr_reader :data, :max_contacts, :status, :report_id

  def post_initialize(params)
    return unless params && (params[:klass_id] || params[:report_id])

    init_filter_values(params) if params[:klass_id]
    @report_id = params[:report_id]
    report_id ? read_cache : start_processing
  end

  def init_filter_values(params)
    @sector_id = params[:sector_id]
    @distance  = params[:distance].to_i.positive? ? params[:distance].to_i : 20
  end

  def process_next
    trainee = data.trainees_data[next_index].trainee
    build_trainee_data(trainee)

    check_max_contacts
    increment_index
    determine_processing_status
    write_cache
    status
  end

  def build_trainee_data(trainee)
    near_by_emp_ids, employers_data = build_employers_data(trainee)

    @data.employer_ids |= near_by_emp_ids # set union operation.
    @data.contact_ids |= Contact.where(contactable_id: near_by_emp_ids).pluck(:id)
    @data.trainees_data[next_index].employers_data = employers_data
    @data.trainees_data[next_index].trainee = trainee
  end

  def build_employers_data(trainee)
    emp_ids = near_by_employer_ids(trainee)
    data.rows_count += emp_ids.count
    emp_data =
      emp_ids.map do |e_id|
        contact_ids = Contact.where(contactable_id: e_id).pluck(:id)
        OpenStruct.new(employer_id: e_id, contact_ids: contact_ids)
      end
    [emp_ids, emp_data]
  end

  def title
    'Trainees & Near By Employers'
  end

  def template
    'trainees_near_by_employers'
  end

  def count
    data.trainees_data.count
  end

  def klass_id
    data&.klass_id
  end

  def klass
    klasses.first
  end

  def max_contacts
    data.max_contacts
  end

  def url_for_process_next
    "/reports/process_next?#{url_report_name_id_part}".html_safe
  end

  def url_for_show
    "/reports/show?#{url_report_name_id_part}".html_safe
  end

  def url_report_name_id_part
    "report_name=trainees_near_by_employers&report_id=#{report_id}"
  end

  def sector_id
    data&.sector_id
  end

  def selected_klass_id
    data&.klass&.id
  end

  def trainee_employers_and_contacts(c)
    trainee = data.trainees_data[c].trainee
    [trainee, employers_and_contacts(c)]
  end

  def employers_and_contacts(n)
    trainee_data = data.trainees_data[n]
    trainee_data.employers_data.map do |ed|
      [@employers_hash[ed.employer_id], @contacts_hash.values_at(*ed.contact_ids)]
    end
  end

  def build_excel
    builder = TraineesNearByEmployersViewBuilder.new(data, 3)
    excel_file = ExcelFile.new(user, 'trainees_and_near_by_employers')
    excel_file.add_row builder.header
    each_row do |trainee, employer, contacts|
      row = builder.build_row(trainee, employer, contacts)
      excel_file.add_row row, 60
    end
    excel_file.save
    excel_file
  end

  def each_row
    data.trainees_data.each_with_index do |td, c|
      trainee = td.trainee
      employers_and_contacts(c).each do |employer, contacts|
        yield trainee, employer, contacts
      end
    end
  end

  private

  def start_processing
    generate_report_id # cache_key

    @data = OpenStruct.new

    @data.klass_id     = @klass_id
    @data.sector_id    = @sector_id
    @data.distance     = @distance
    @data.max_contacts = 1
    @data.next_index   = 0
    @data.employer_ids = []
    @data.contact_ids  = []
    @data.rows_count   = 0

    find_sector_employers
    init_klass_trainees
    determine_processing_status
    write_cache
  end

  def init_klass_trainees
    @data.klass = klass
    @data.trainees_data =
      klass.trainees.order(:first, :last).map { |t| OpenStruct.new(trainee: t) }
  end

  def near_by_employer_ids(trainee)
    return [] unless trainee.home_address

    ta = trainee.home_address
    a = Address.new(latitude: ta.latitude, longitude: ta.longitude)
    a.id = ta.id
    near_by_emp_ids = a.nearbys(radius)
                       .where(addressable_type: 'Employer',
                              addressable_id: sector_employers_ids)
                       .map(&:addressable_id)

    a.id = nil
    a.delete
    near_by_emp_ids
  end

  def next_index
    @data.next_index
  end

  def increment_index
    @data.next_index += 1
  end

  def determine_processing_status
    @status = @data.trainees_data[next_index].nil? ? 'done' : 'pending'
  end

  def sector_employers_ids
    @data[:sector_employers_ids]
  end

  def check_max_contacts
    employers_data = @data.trainees_data[next_index].employers_data
    mc = employers_data.map { |ed| ed.contact_ids.count }.max
    @data.max_contacts = mc if mc.to_i > max_contacts
  end

  def find_sector_employers
    @data[:sector_employers_ids] = EmployerSector.where(sector_id: sector_id)
                                                 .pluck(:employer_id)
  end

  def generate_report_id
    loop do
      @report_id = "TraineesNearByEmployersReport_#{user_id}_#{rand(1000)}"
      return unless Rails.cache.exist?(report_id)
    end
  end

  def write_cache
    Rails.cache.write(report_id, @data, expires_in: 1.hour)
  end

  def read_cache
    @data = Rails.cache.read(report_id)
    @distance = @data.distance
    fetch_employers_and_contacts if processing_complete?
  end

  def processing_complete?
    determine_processing_status
    @status == 'done'
  end

  def fetch_employers_and_contacts
    fetch_employers
    contacts = Contact.where(id: @data.contact_ids).decorate
    @contacts_hash = Hash[*contacts.map { |contact| [contact.id, contact] }.flatten]
  end

  def fetch_employers
    employers = Employer.includes(:address, :employer_source)
                        .where(id: @data.employer_ids)
    @employers_hash = Hash[*employers.map { |employer| [employer.id, employer] }.flatten]
  end
end
