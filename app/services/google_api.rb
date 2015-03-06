# encoding: utf-8

require 'fusion_tables'
require 'rest_client'
require 'json'
require 'fuzzystringmatch'

# wrapper for google api to find companies and county polygons
class GoogleApi
  NEARBY_SEARCH_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  DETAILS_URL       = 'https://maps.googleapis.com/maps/api/place/details/json'
  TEXT_SEARCH_URL   = 'https://maps.googleapis.com/maps/api/place/textsearch/json'

  COUNTY_POLYGON_QRY = 'SELECT geometry FROM 1xdysxZ94uUFIit9eXmnw1fYc6VcQiXhceFd_CVKa ' \
                       "WHERE 'State-County' = "

  SHORT_NAME        = 'short_name'
  LONG_NAME         = 'long_name'

  def self.get_circle_marker(radius, lng, lat, stroke_color = nil, fill_color = nil)
    circle = { lng: lng, lat: lat, radius: radius * 1609.34,
               fillOpacity: 0.15, strokeWeight: 1 }
    circle[:strokeColor] = stroke_color || (radius == 10 ? '#00FF00' : '#FF0000')
    circle[:fillColor] = fill_color || (radius == 10 ? '#8F8' : '#88F')
    circle
  end

  def self.search_for_companies(name, city_state)
    return nil if city_state.blank? || name.blank?
    options = { query: "#{name} near #{city_state}" }
    json    = search(TEXT_SEARCH_URL, options)
    return nil unless json && json['results']

    city_name  = city_state.split(',')[0]
    state_code = city_state.split(',')[1]
    companies  = []
    json['results'].each do |result|
      result[:score] = place_matching_score(result, name, city_name, state_code)
      companies.push GoogleCompany.new(result)
    end
    companies.sort! { |a, b| b.score <=> a.score }
    companies[0..19]
  end

  def self.load_county_polygon(county)
    state_county = county.state_code.upcase + '-' + county.name

    ft = GData::Client::FusionTables.new
    ft.set_api_key(ENV['GOOGLE_KEY'])
    qry = COUNTY_POLYGON_QRY + "'#{state_county}';"

    data = ft.execute qry

    if data.empty? && state_county.include?(' ')
      # try with a dash in the county name
      qry =  COUNTY_POLYGON_QRY + "'#{state_county.gsub(' ', '-')}';"
      data = ft.execute qry
      return nil if data.empty?
    end

    geometry = data[0][:geometry]

    if geometry['geometry']
      coordinates_array = geometry['geometry']['coordinates'][0]
      coordinates_hashes = coordinates_array.map { |a| { 'lng' => a[0], 'lat' => a[1] } }
      county.polygons.new(json: coordinates_hashes.to_json)
    elsif geometry['geometries'] # some counties can have multiple polygons
      geometry['geometries'].each do |g|
        coordinates_array = g['coordinates'][0]
        coordinates_hashes = coordinates_array.map do |a|
                               { 'lng' => a[0], 'lat' => a[1] }
                             end
        county.polygons.new(json: coordinates_hashes.to_json)
      end
    end
    county.save
  end

  def self.find_company_with_score(name, city_name, state_code,
                                   latitude, longitude)
    json = text_search(query: "#{name} near #{city_name},#{state_code}")

    return nil unless json && json['status'] == 'OK'
    matches = get_best_matches(json, name, city_name, state_code)
    score = matches[0][:score]
    if score < 70
      # should try nearby search
      options = { location: "#{latitude},#{longitude}",
                  radius:   50_000,
                  types:    'establishment',
                  name:     name }

      json = near_by_search(options)
      return nil unless json['status'] == 'OK'
      matches = get_best_matches(json, name, city_name, state_code)
    end

    return nil if matches[0][:score] < 60

    reference = matches[0][:reference]
    json = details(reference: reference)
    [matches[0][:score], json]
  end

  def self.find_company(name, city_name, state_code,
                                           latitude, longitude)
    score, json = find_company_with_score(name, city_name, state_code,
                                          latitude, longitude)
    return nil unless json

    addr_comp = json['address_components']
    address_info = build_address_info(addr_comp, json['formatted_address'])
    return nil unless address_info

    json.merge!(address_info)

    json[:score] = score
    json[:score] -= 30 unless json[:city]

    GoogleCompany.new(json)
  end

  def self.place_matching_score(result, name, city_name, state_code)
    jarow = FuzzyStringMatch::JaroWinklerPure.new
    score = 5
    score += 75 * jarow.getDistance(name.downcase, result['name'].downcase)
    if result['formatted_address']
      address = result['formatted_address'].downcase.split(',')
      score += 10 * jarow.getDistance(address[1].squish, city_name.downcase) if address[1]
      score += 10 if state_code.downcase == address[2].squish.downcase if address[2]
    end
    score.round
  end

  def self.get_best_matches(json, name, city_name, state_code)
    matches = []
    count = 0
    json['results'][0..4].each do |result|
      count += 1
      score = place_matching_score(result, name, city_name, state_code)
      match = { score: score, index: count, reference: result['reference'] }
      matches.push match
    end

    matches.sort! { |a, b| b[:score] <=> a[:score] }

    # debugger
    matches
  end

  def self.text_search(options)
    search(TEXT_SEARCH_URL, options)
  end

  def self.near_by_search(options)
    search(NEARBY_SEARCH_URL, options)
  end

  def self.details(options)
    details = search(DETAILS_URL, options)
    details['result']
  end

  def self.search(url, options)
    options = options.merge(key: ENV['GOOGLE_KEY'], sensor: :false)
    response = RestClient.get(url, params: options)
    JSON.parse response.body
  end

  def self.build_address_info(address_components, formatted_address)
    address = parse_address_components(address_components)

    state_not_in_usa = address[:state] && !State.valid_state_code?(address[:state])
    # it should be a state in USA
    return nil if state_not_in_usa

    parsed_address = parse_formatted_address(formatted_address)
    address.merge!(parsed_address || {}) if address[:city].nil? && formatted_address
    if address[:line1].nil? && address[:city] && formatted_address
      address_parts = formatted_address.split(',')
      address[:line1] = address_parts[0] if address_parts[1] &&
                                            address_parts[1].squish == address[:city]
    end

    unless address[:county]
      if address[:city] && address[:state]
        city_state = "#{address[:city]},#{address[:state]}".downcase
        city_result = GeoServices.findcity(city_state, address[:zip])
        address[:county] = city_result && city_result.county_name
      end
    end

    address
  end

  def self.parse_address_components(acs)
    attrs     = %w(street_number route locality sublocality
                   administrative_area_level_1 postal_code)
    attrs_map = %i(street_number street city sublocality
                   state_code zip)

    address = {}

    acs.each do |d|
      ind = attrs.index(d['types'][0])
      address[attrs_map[ind]] = d[SHORT_NAME] if ind
    end
    address[:state] = address[:state_code]
    address[:city] ||= address[:sublocality]
    address[:line1] = build_line1(address)

    address
  end

  def self.build_line1(address)
    return nil unless address[:street] && address[:street_number]
    address[:street_number] + ' ' + address[:street]
  end

  def self.parse_formatted_address(fa)
    searchres = GeoServices.perform_search(fa)
    # searchres = Geocoder.search fa
    # if searchres.size == 0
    #   # try one more time
    #   sleep 0.5
    #   searchres = Geocoder.search fa
    # end

    return nil if searchres.size == 0

    gs = searchres[0]
    return nil unless gs.country_code == 'US'

    addr = {}

    addr[:line1] = gs.street_address
    addr[:city]  = gs.city
    addr[:state] = gs.state_code
    addr[:zip]   = gs.postal_code

    county_component = gs.address_components_of_type('administrative_area_level_2')
    valid_county = county_component && county_component[0]
    addr[:county] = county_component[0][LONG_NAME] if valid_county

    if addr[:zip] && !addr[:city]
      city = City.where(zip: addr[:zip]).first
      if city
        addr[:city] = city.name
        addr[:county] = city.county_name
      end
    end

    if addr[:city] && addr[:state] && !addr[:county]
      city = GeoServices.findcity("#{addr[:city]},#{addr[:state]}", addr[:zip])
      addr[:county] = city && city.county_name
    end

    # if county name is found, then make sure it is in the state
    if addr[:county]
      state = State.check_and_get(addr[:state])
      county = state && state.get_county(addr[:county])
      addr[:county] = nil unless county
    end

    addr
  end
end
