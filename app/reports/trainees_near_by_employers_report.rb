# contains data for employers near trainees report
class TraineesNearByEmployersReport < Report
  attr_reader :data, :max_contacts, :status, :report_id
  def post_initialize(params)
    return unless params && (params[:klass_id] || params[:report_id])
    init_filter_values(params) if params[:klass_id]
    @report_id = params[:report_id]
    report_id ? read_cache : start_processing
  end

  def init_filter_values(params)
    @sector_id = params[:sector_id]
    @radius    = (params[:distance] || 20).to_i
  end

  def process_next
    trainee = @data.trainees_data[next_index].trainee

    near_by_emp_ids = near_by_employer_ids(trainee)
    employers_data = near_by_emp_ids.map do |employer_id|
      employer_data = OpenStruct.new
      employer_data.employer_id = employer_id
      employer_data.contact_ids = Contact.where(contactable_id: employer_id).pluck(:id)
      employer_data
    end
    @data.employer_ids |= near_by_emp_ids
    @data.contact_ids |= Contact.where(contactable_id: near_by_emp_ids).pluck(:id)
    @data.trainees_data[next_index].employers_data = employers_data
    @data.trainees_data[next_index].trainee = trainee.decorate
    check_max_contacts
    increment_index
    determine_processing_status
    write_cache
    @status
  end

  def count
    @data.trainees_data.count
  end

  def klass_id
    klass_ids && klass_ids.first
  end

  def klass
    klasses.first
  end

  def max_contacts
    @data.max_contacts
  end

  def url_for_process_next
    "/reports/process_next?report=trainees_near_by_employers&report_id=#{report_id}"
  end

  def url_for_show
    "/reports/show?report=trainees_near_by_employers&report_id=#{report_id}"
  end

  def sector_id
    @data && @data.sector_id
  end

  def radius
    (@data && @data.radius) || 10
  end

  def selected_klass_id
    @data && @data.klass.id
  end

  def trainee_employers_and_contacts(c)
    trainee = @data.trainees_data[c].trainee
    [trainee, employers_and_contacts(c)]
  end

  def employers_and_contacts(n)
    trainee_data = @data.trainees_data[n]
    trainee_data.employers_data.map do |ed|
      [@employers_hash[ed.employer_id], @contacts_hash.values_at(*ed.contact_ids)]
    end
  end

  private

  def start_processing
    generate_report_id # cache_key

    @data = OpenStruct.new
    @data.sector_id = @sector_id
    @data.radius = @radius
    @data.max_contacts = 1
    @data.next_index = 0
    @data.employer_ids = []
    @data.contact_ids = []
    find_sector_employers
    init_klass_trainees
    determine_processing_status
    write_cache
  end

  def init_klass_trainees
    @data.klass = klass
    @data.trainees_data = klass.trainees.order(:first, :last).map do |trainee|
      t_os = OpenStruct.new
      t_os.trainee = trainee
      t_os
    end
  end

  def near_by_employer_ids(trainee)
    return [] unless trainee.home_address
    trainee_address = trainee.home_address
    a = Address.new(latitude: trainee_address.latitude,
                    longitude: trainee_address.longitude)
    a.id = trainee_address.id
    near_by_emp_ids = a.nearbys(radius)
                       .where(addressable_type: 'Employer',
                              addressable_id: sector_employers_ids)
                       .map { |addr| addr.addressable_id }
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
      @report_id = 'TraineesNearByEmployersReport_' + user_id.to_s + '_' + rand(1000).to_s
      return unless Rails.cache.exist?(report_id)
    end
  end

  def write_cache
    Rails.cache.write(report_id, @data, expires_in: 1.hour)
  end

  def read_cache
    @data = Rails.cache.read(report_id)
    fetch_employers_and_contacts if processing_complete?
  end

  def processing_complete?
    determine_processing_status
    @status == 'done'
  end

  def fetch_employers_and_contacts
    employers = Employer.includes(:address).where(id: @data.employer_ids).decorate
    @employers_hash = Hash[*employers.map { |employer| [employer.id, employer] }.flatten]

    contacts = Contact.where(id: @data.contact_ids).decorate
    @contacts_hash = Hash[*contacts.map { |contact| [contact.id, contact] }.flatten]
  end
end
