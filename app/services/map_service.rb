# generates markers and infowindows for addresses
# this can be used in 2 ways
# 1. subclassing
# 2. directly by passing addressess
class MapService
  attr_reader :markers_json, :addresses

  def initialize(p_addresses = nil)
    return unless p_addresses
    @addresses = p_addresses
    generate_markers_json
  end

  def map
    { markers: { data: markers_json }, map_options: { raw: '{scaleControl: true}' } }
  end

  def generate_markers_json
    @markers_json = addresses.to_gmaps4rails do |addr, marker|
      entity = addr.addressable
      if entity
        marker.infowindow get_info_window(addr)
        marker.title entity.name
        pic = get_marker_pic(entity)
        marker.picture(picture: pic) if pic
        marker.json(name: entity.name)
      else
        # debugger
        puts "addressable is nil for address id: #{addr.id} - #{addr.gmaps4rails_address}"
      end
    end

    @markers_json
  end

  private

  def get_info_window(address)
    obj = address.addressable
    if obj
      color =  'lightsalmon' if obj.is_a?(Employer)
      color ||= obj.is_a?(Trainee) ? 'lightgreen' : 'lightgrey'
      if obj.is_a?(Employer)
        sectors =  '<ol>' +
                    obj.sectors.map { |sector| "<li>#{sector.name}</li>" }.join +
                    '</ol>'
      else
        sectors =  ''
      end
      "<div style='background-color:#{color}'>
        <p><b>#{obj.name}</b></p>
        #{address.line1}<br>
        #{address.city}<br>
        #{address.state} #{address.zip}<br>
        #{sectors}
      </div>"
    end
  end

  def get_marker_pic(obj)
    pic_file = nil # default for employer
    pic_file = 'college.png' if obj.is_a?(College)
    pic_file = 'trainee_green.png' if obj.is_a?(Trainee)
    pic_file && ActionController::Base.helpers.asset_path(pic_file)
  end

  def build_circles(addr)
    return [] unless addr
    [10, 20].map do |radius|
      GoogleApi.get_circle_marker(radius, addr.longitude, addr.latitude)
    end
  end
end
