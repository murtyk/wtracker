# for rendering employers on map
class EmployersMap < MapService
  attr_reader :filters, :employers, :employers_addresses,
              :state_county_polygons, :state_county_names

  def initialize(in_filters)
    @filters = in_filters || {}
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
    return [] unless @employers
    @employers.decorate
  end

  def employers_addresses
    @employers_addresses || []
  end

  private

  def county_ids
    unless @county_ids
      @county_ids = filters[:county_ids] || []
      @county_ids.delete('')
    end
    @county_ids
  end

  def county_names
    County.where(id: county_ids).pluck(:name)
  end

  def init_employer_and_addresses
    return unless !name.blank? || county_ids.size > 0 || sector_id > 0
    employer_ids = EmployerServices.new(filters).search.pluck(:id)
    return if employer_ids.empty?
    @employers_addresses = Address.where(addressable_type: 'Employer',
                                         addressable_id: employer_ids)
    employer_ids = @employers_addresses.pluck(:addressable_id)
    return if employer_ids.empty?
    @employers = Employer.includes(:sectors, :contacts)
                         .where(id: employer_ids).order(:name)
  end

  def college_addresses
    return [] unless show_colleges?
    Address.includes(:addressable).where(addressable_type: 'College')
  end

  def trainee_addresses
    return [] unless klass_id > 0
    trainee_ids = Klass.find(klass_id).trainees.pluck(:id)
    HomeAddress.includes(:addressable)
               .where(addressable_type: 'Trainee', addressable_id: trainee_ids)
  end

  def init_addresses
    init_employer_and_addresses
    @addresses = employers_addresses + college_addresses + trainee_addresses
  end

  def init_county_name_and_polygons_of_state
    @state_county_polygons = []
    @state_county_names = []
    state = Account.states.first
    if state
      state.counties.each do |county|
        @state_county_polygons += county.polygons_json
        @state_county_names.push county.name
      end
    end
  end
end
