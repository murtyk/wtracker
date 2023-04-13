# frozen_string_literal: true

# for finding valid address, city, county or latlong
class GeoServices
  ADMIN_LVL2 = 'administrative_area_level_2'
  def self.parse(location)
    # debugger
    searchres = perform_search location
    raise "Geocoding failed for address #{location}" if searchres.size.zero?

    result = searchres[0]
    addr = build_address_object_from_result(result)
    addr.cty = sublocality_from_result(result) unless addr.city

    determine_county_zip_from_city(addr)

    addr
  end

  def self.determine_county_zip_from_city(addr)
    unless addr.county && addr.zip
      city = findcity("#{addr.city},#{addr.state}", addr.zip)
      addr.county ||= city.county_name
      addr.zip ||= city.zip
    end
  end

  def self.sublocality_from_result(result)
    sc = result.address_components_of_type('sublocality')
    sc && sc[0] && sc[0]['long_name']
  end

  def self.build_address_object_from_result(result)
    addr = Address.new

    address_attributes = %w[street_address city postal_code state_code latitude longitude]
    address_attributes.each { |attr| addr.send("#{attr}=", result.send(attr)) }

    county_components = result.address_components_of_type(ADMIN_LVL2)
    addr.county = county_components &&
                  county_components[0] && county_components[0]['long_name']

    addr
  end

  def self.findcity(location, zip = nil)
    city = find_city_from_db(location, zip)
    return city if city

    # debugger
    parts = location.downcase.split(',')
    loc = parts.map(&:squish).join(',')

    data, city_name, state = search_for_city_state(loc + (zip && ",#{zip}").to_s)

    return nil unless data && state

    county = county_from_search_result(data, state)
    return nil unless county

    # KORADA in some cases, nearest city is returned than the actual town.
    # in case of 'Jackson Heights, NY' we get New York as city
    # solution: take part[0] of formatted address if that matches our city
    unless city_name.downcase == parts[0]
      address_parts = data.formatted_address.split(',')
      city_name = address_parts[0]
    end

    # KORADA for 'Sparta, NJ' we get 'Sparta Township'.
    # solution: check if it exists
    city = City.find_by_citystate("#{city_name},#{state.code}")
    return city if city

    create_city(state, city_name, county, data)
  end

  def self.find_city_from_db(location, zip = nil)
    parts = location.downcase.split(',')
    loc = parts.map(&:squish).join(',')
    city = City.where("REPLACE(city_state,' ','') = ? AND zip = ?", loc, zip).first if zip
    city ||= City.find_by_citystate(loc)
    city
  end

  def self.search_for_city_state(location)
    return [] if location.downcase == 'nationwide'

    results = perform_search(location)
    return [] if results.empty?

    results.each do |result|
      city_name = result.city || (result.postal_code && result.neighborhood)
      next unless city_name
      next unless result.state_code

      state_code = result.state_code.upcase
      state = State.check_and_get(state_code)
      return [result, city_name, state] if state
    end

    []
  end

  def self.county_from_search_result(data, state)
    county_component = data.address_components_of_type(ADMIN_LVL2)[0]
    county_name = county_component && county_component['short_name']

    unless county_name
      # KORADA for some locations (New York, NY) it does not
      # provide county since there could be many
      # solution: use the approximate latlong and reverse gecode
      results = perform_search([data.latitude, data.longitude])
      c_component = results && results[0].address_components_of_type(ADMIN_LVL2)[0]
      return nil unless c_component

      county_name = c_component['short_name']
    end

    state.get_county(county_name)
  end

  def self.create_city(state, city_name, county, data)
    data_zip = zip_from_result(data)
    state.cities.create(name: city_name, county_id: county.id,
                        latitude: data.latitude,
                        longitude: data.longitude,
                        zip: data_zip)
  end

  def self.zip_from_result(data)
    return data.postal_code if data.postal_code

    return nil unless data.longitude && data.latitude

    # KORADA reverse geocode to find zip
    results = perform_search("#{data.latitude},#{data.longitude}")
    results.each do |result|
      return result.postal_code if result.postal_code
    end
    nil
  end

  def self.findcounty(address)
    r = perform_search(address)

    return nil if r.blank?

    parts = r[0].address_components
    parts.each do |part|
      return part['long_name'] if part['types'][0] == ADMIN_LVL2
    end
    nil
  end

  def self.latlong(location)
    r = perform_search(location)
    return nil if r.blank?

    [r[0].latitude, r[0].longitude]
  end

  def self.perform_search(location)
    result = Geocoder.search(location)
    return result unless result.blank?

    # try one more time
    sleep 1
    Geocoder.search(location)
  rescue StandardError => e
    Rails.logger.error("GeoServices: location: #{location} error: #{e}")
    []
  end
end
