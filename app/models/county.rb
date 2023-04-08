# frozen_string_literal: true

# a county in USA.
# belongs to a state
# has polygon(s) for rendering on map
class County < ApplicationRecord
  belongs_to :state
  has_many :cities

  has_many :polygons, as: :mappable, dependent: :destroy

  def self.search(filters, include_polygons = false)
    counties = find_counties(filters)
    return [counties, []] unless include_polygons

    [counties, counties_polygons(counties)]
  end

  def polygons_json
    FusionTable.load_county_polygon(self) if polygons.empty?
    [JSON.parse(polygons.first.json)]
  end

  def state_code
    state.code.upcase
  end

  def state_and_county_names
    "#{state_code} - #{name}"
  end

  def self.find_counties(filters)
    name = filters[:name]
    state = state_from_filters(filters)

    return [] if name.blank? && !state

    counties = state ? state.counties : all
    counties = counties.where('name ilike ?', "#{name}%") unless name.blank?
    counties.order(:name)
  end

  def self.state_from_filters(filters)
    return if filters[:state_id].blank?

    State.find(filters[:state_id])
  end

  def self.counties_polygons(counties)
    polies = []
    counties.each { |county| polies += county.polygons_json }
    polies
  end

  # def self.find_by_city_and_state(city_name, state_code)
  #   state = State.where(code: state_code).first
  #   return nil unless state
  #   county_name = GeoServices.findcounty("#{city_name},#{state_code}")
  #   return nil unless county_name
  #   county = state.counties.where(name: county_name).first
  #   return county if county
  #   county_name = county_name.gsub('County', '').squish
  #   state.counties.where(name: county_name).first
  # end
end
