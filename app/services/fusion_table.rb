# frozen_string_literal: true

require 'fusion_tables'
require 'rest_client'
require 'json'

# wrapper for google fusion table to find county polygons
class FusionTable
  COUNTY_POLYGON_QRY = 'SELECT geometry FROM 1xdysxZ94uUFIit9eXmnw1fYc6VcQiXhceFd_CVKa ' \
                       "WHERE 'State-County' = "

  def self.load_county_polygon(county)
    geometry = find_county_geometry(county)

    return nil unless geometry
    return nil unless geometry['geometry'] || geometry['geometries']

    coordinates = build_county_coordinates(geometry)

    coordinates.each do |coord|
      county.polygons.new(json: coord)
    end
    county.save
  end

  def self.build_county_coordinates(geometry)
    # some counties can have multiple polygons
    g_array = geometry['geometries'] || [geometry['geometry']]

    g_array.map do |g|
      coord_array = g['coordinates'][0]
      coord_array.map { |a| { 'lng' => a[0], 'lat' => a[1] } }.to_json
    end
  end

  def self.find_county_geometry(county)
    state_county = "#{county.state_code.upcase}-#{county.name}"
    data = search_county_polygon(state_county)

    if data.empty? && state_county.include?(' ')
      # try with a dash in the county name
      data = search_county_polygon(state_county.gsub(' ', '-'))
    end
    return nil if data.empty?

    data[0][:geometry]
  end

  def self.search_county_polygon(state_county)
    ft = GData::Client::FusionTables.new
    ft.set_api_key(ENV['GOOGLE_KEY'])
    qry = COUNTY_POLYGON_QRY + "'#{state_county}';"
    ft.execute qry
  end
end
