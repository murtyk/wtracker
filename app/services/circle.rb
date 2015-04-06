# represents a circle on google map
class Circle
  attr_accessor :radius, :lng, :lat
  def initialize(radius, lng, lat)
    @radius = radius
    @lng = lng
    @lat = lat
  end

  def marker(stroke_color = nil, fill_color = nil)
    mark = { lng: lng, lat: lat, radius: radius * 1609.34,
             fillOpacity: 0.15, strokeWeight: 1 }
    mark[:strokeColor] = stroke_color || (radius == 10 ? '#00FF00' : '#FF0000')
    mark[:fillColor] = fill_color || (radius == 10 ? '#8F8' : '#88F')
    mark
  end
end
