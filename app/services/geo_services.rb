# encoding: utf-8
# for finding valid address, city, county or latlong
class GeoServices
  ADMIN_LVL2 = 'administrative_area_level_2'
  def self.parse(location, _zip = nil)
    # debugger
    searchres = perform_search location
    fail "Geocoding failed for address #{location}" if searchres.size == 0

    result = searchres[0]
    addr = Address.new

    address_attributes = %w(street_address city postal_code state_code latitude longitude)
    address_attributes.each { |attr| addr.send("#{attr}=", result.send(attr)) }

    county_components = result.address_components_of_type(ADMIN_LVL2)
    addr.county = county_components &&
      county_components[0] && county_components[0]['long_name']

    unless addr.city
      sublocality_components = result.address_components_of_type('sublocality')
      addr.city = sublocality_components &&
        sublocality_components[0] && sublocality_components[0]['long_name']
    end

    unless addr.county && addr.zip
      city = findcity("#{addr.city},#{addr.state}", addr.zip)
      addr.county ||= city.county_name
      addr.zip ||= city.zip
    end

    addr
  end

  def self.findcity(location, zip = nil)
    parts = location.downcase.split(',')
    loc = parts.map(&:squish).join(',')
    city = City.where("REPLACE(city_state,' ','') = ? AND zip = ?", loc, zip).first if zip
    city ||= City.find_by_citystate(loc)

    return city if city

    # debugger
    results = perform_search(loc + (zip && ",#{zip}").to_s)
    return nil if results.empty?

    city_name = nil
    data = nil
    results.each do |result|
      city_name = result.city || (result.postal_code && result.neighborhood)
      data = result if city_name
      break if city_name
    end

    return nil unless data

    state_code = data.state_code.upcase
    state = State.check_and_get(state_code)

    return nil unless state

    if data.address_components_of_type(ADMIN_LVL2)[0].nil?
      # KORADA for some locations (New York, NY) it does not
      # provide county since there could be many
      # solution: use the approximate latlong and reverse gecode
      result1 = perform_search([data.latitude, data.longitude])
      return nil if result1.empty?
      data1 = result1[0]
      return nil if data1.address_components_of_type(ADMIN_LVL2)[0].nil?
      county_name = data1.address_components_of_type(ADMIN_LVL2)[0]['short_name']
    else
      county_name = data.address_components_of_type(ADMIN_LVL2)[0]['short_name']
    end

    county = state.get_county(county_name)
    return nil unless county

    # KORADA in some cases, nearest city is returned than the actual town.
    # in case of 'Jackson Heights, NY' we get New York as city
    # solution: take part[0] of formatted address if that matches our city

    unless city_name.downcase == parts[0]
      address_parts = data.formatted_address.split(',')
      city_name = address_parts[0]
    end

    city_state = "#{city_name},#{state.code}"

    # KORADA for 'Sparta, NJ' we get 'Sparta Township'.
    # solution: check if it exists
    city = City.find_by_citystate(city_state)
    return city if city

    data_zip = data.postal_code

    if data_zip.nil? && data.longitude && data.latitude
      # KORADA reverse geocode to find zip
      results = perform_search("#{data.latitude},#{data.longitude}")
      results.each do |result|
        if result.postal_code
          data_zip = result.postal_code
          break
        end
      end
    end

    state.cities.create(name: city_name, county_id: county.id,
                        latitude: data.latitude,
                        longitude: data.longitude,
                        zip: data_zip)
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
  end
end
