# for rendering employers on map
class EmployersMap < MapService
  attr_reader :filters, :employers, :employers_addresses,
              :state_county_polygons, :state_county_names,
              :user

  def initialize(user, in_filters)
    @user = user
    @filters = in_filters || {}
    @employer_ids = []
    return unless in_filters

    init_addresses
    init_county_name_and_polygons_of_state

    generate_markers_json
  end

  def name
    filters[:name]
  end

  def sector_id
    filters[:sector_id].to_i
  end

  def klass_id
    filters[:klass_id].to_i
  end

  def selected_county_ids
    county_ids
  end

  def searched_county_names
    name.blank? && county_names.join(',')
  end

  def searched_sector_name
    name.blank? && sector_name
  end

  def sector_name
    Sector.find(sector_id).name if sector_id > 0
  end

  def show_colleges?
    @show_colleges ||= filters[:show_colleges].to_i == 1
  end

  def near_by_trainees?
    filters[:near_by_trainees]
  end

  def circles
    return nil unless employers_addresses.count == 1 && employers.count == 1
    return @circles if @circles
    employer = employers.first
    @circles = build_circles(employer.address)
  end

  def map
    return super unless circles
    super.merge(circles: { data:  circles.to_json })
  end

  def employers
    return [] unless @employer_ids.any?
    Employer.includes(:employer_sectors, :sectors, :contacts, :employer_source, :address)
      .where(id: @employer_ids).order(:name)
  end

  def employers_addresses
    @employers_addresses || []
  end

  def trainees
    Trainee.includes(:klass_trainees, :klasses).where(id: trainee_ids)
  end

  def trainee_ids
    @trainee_addresses.map(&:addressable_id)
  end

  def trainee_names
    trainees.map(&:name)
  end

  private

  def county_ids
    @county_ids ||= (filters[:county_ids] || []) - ['']
  end

  def county_names
    County.where(id: county_ids).pluck(:name)
  end

  def valid_filters?
    return true if near_by_trainees?
    !name.blank? || county_ids.size > 0 || sector_id > 0
  end

  def employer_ids_to_search
    return @filters[:id] if near_by_trainees?
    @e_search_ids ||= EmployerServices.new(user, filters).search.pluck(:id)
  end

  def college_addresses
    return [] unless show_colleges?
    Address.includes(:addressable).where(addressable_type: 'College')
  end

  def find_trainee_addresses
    return find_near_by_trainees_addresses if near_by_trainees?

    unless klass_id > 0
      @trainee_addresses = []
      return
    end

    t_ids = Klass.find(klass_id).trainees.pluck(:id)
    @trainee_addresses = HomeAddress.includes(:addressable)
                         .where(addressable_type: 'Trainee', addressable_id: t_ids)
  end

  def employer_address
    @employers_addresses[0]
  end

  def radius
    (@filters[:radius] || 20).to_i
  end

  def find_near_by_trainees_addresses
    a = search_address(employer_address)
    @trainee_addresses = a.nearbys(radius)
                         .where(addressable_type: 'Trainee')
                         .where(addressable_id: not_hired_trainee_ids)
    a.id = nil
    a.delete
  end

  def not_hired_trainee_ids
    user_trainee_ids - TraineeInteraction.where(status: [4, 6], termination_date: nil)
      .pluck(:trainee_id)
  end

  def search_address(address)
    a = Address.new(latitude:  address.latitude,
                    longitude: address.longitude)
    a.id = address.id
    a
  end

  def user_trainee_ids
    return Trainee.pluck(:id) if user.admin_access?
    k_ids = user.klasses.pluck(:id)
    Trainee.joins(:klass_trainees).where(klass_trainees: { klass_id: k_ids }).pluck(:id)
  end

  def init_addresses
    init_employer_and_addresses
    find_trainee_addresses
    @addresses = employers_addresses + college_addresses + @trainee_addresses
  end

  def init_employer_and_addresses
    return unless valid_filters?
    return if employer_ids_to_search.empty?
    @employers_addresses = Address.includes(:addressable)
                           .where(addressable_type: 'Employer',
                                  addressable_id: employer_ids_to_search)
    @employer_ids = @employers_addresses.map(&:addressable_id)
  end

  def init_county_name_and_polygons_of_state
    @state_county_polygons = []
    @state_county_names = []
    state = Account.states.first
    return unless state

    state.counties.includes(:polygons).each do |county|
      @state_county_polygons += county.polygons_json
      @state_county_names << county.name
    end
  end
end
