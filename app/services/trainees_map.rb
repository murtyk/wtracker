# wrapper for rendering trainee(s) and near by employers
class TraineesMap < MapService
  attr_reader :employers, :trainee_address, :error, :user

  def initialize(user, filters)
    @user = user
    defaults
    @filters = filters
    return unless filters && filters[:klass_id]

    init_addresses
    generate_markers_json
  end

  def defaults
    @addresses = []
    @trainees = []
  end

  def radius
    (@filters && @filters[:radius] || 10).to_i
  end

  def sector_id
    @filters && @filters[:sector_id].to_i
  end

  def klass_id
    @filters && @filters[:klass_id].to_i
  end

  def trainee_id
    @filters && @filters[:trainee_id].to_i
  end

  def trainee
    Trainee.find(trainee_id)
  end

  def klass
    @klass ||= klass_id && Klass.find(klass_id)
  end

  def klass_trainees
    (klass && klass.trainees.includes(:home_address)) || []
  end

  def trainees
    trainee_id.to_i > 0 ? Trainee.where(id: trainee_id) : klass_trainees
  end

  def near_by_employers?
    @near_by_employers ||= @filters && (@filters[:near_by_employers] == '1')
  end

  def show_near_by_employers?
    near_by_employers? && employers && !error
  end

  def circles
    @circles ||= build_circles(trainee_address)
  end

  def map
    return nil if near_by_employers? && error
    return super unless near_by_employers?
    super.merge(circles: { data:  circles.to_json })
  end

  private

  def init_addresses
    near_by_employers? ? init_employer_addresses : init_trainees_addresses
  end

  def init_trainees_addresses
    @addresses = HomeAddress
                 .includes(:addressable)
                 .where(addressable_id: trainees.pluck(:id))
  end

  def init_employer_addresses
    @trainee_address = trainee.home_address

    unless trainee_address
      @error = "Home Address is not available for #{trainee.name}"
      return
    end

    employers_addresses = near_by_employers_addresses
    @addresses = [trainee_address] + employers_addresses
    # @employers = employers_addresses.map(&:addressable)

    e_ids = employers_addresses.map(&:addressable_id)
    @employers = Employer.includes(:address, :employer_notes).where(id: e_ids)
  end

  private

  def employers_ids
    user.employers.select(:id)
      .joins(:sectors)
      .where(sectors: { id: sector_id })
      .pluck(:id)
  end

  # since @trainee_address is HOME_ADDRESS,
  # geocoder.nearby looks for only HOME_ADDRESSES
  # SOLUTION: create a new address with same coordinates but don't save it
  def near_by_employers_addresses
    a = Address.new(latitude: trainee_address.latitude,
                    longitude: trainee_address.longitude)
    a.id = trainee_address.id
    e_addresses = a.nearbys(radius)
                  .includes(addressable: [:sectors, :employer_source])
                  .where(addressable_type: 'Employer', addressable_id: employers_ids)
    a.id = nil
    a.delete
    e_addresses
  end
end
