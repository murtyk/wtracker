# wrapper for rendering colleges on a map
class CollegesMap < MapService
  attr_reader :colleges
  def initialize
    init_addresses
    init_klasses_counts
    generate_markers_json
  end

  def init_addresses
    @colleges  = College.includes(:address)
    college_ids = @colleges.pluck(:id)
    @addresses = Address
                 .includes(:addressable)
                 .where(addressable_type: 'College',
                        addressable_id: college_ids)
  end

  def init_klasses_counts
    @klasses_counts = Klass.group(:college_id).count
  end

  def klasses_count(college)
    @klasses_counts[college.id]
  end
end
