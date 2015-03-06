# wrapper for rendering colleges on a map
class CollegesMap < MapService
  attr_reader :colleges
  def initialize
    init_addresses
    generate_markers_json
  end

  def init_addresses
    @colleges  = College.includes(:address).load
    @addresses = @colleges.map(&:address)
  end
end
