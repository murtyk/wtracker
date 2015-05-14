# the main purpose of this is to build a valid address with all components
# from the google company data
# it will use a variety of techniques to find all the components
class GoogleAddress
  SHORT_NAME        = 'short_name'
  LONG_NAME         = 'long_name'

  attr_accessor :address

  def initialize
    @address = {}
  end

  def build_address(address_components, formatted_address)
    parse_address_components(address_components)
    state_not_in_usa = address[:state] && !State.valid_state_code?(address[:state])
    # it should be a state in USA
    return nil if state_not_in_usa

    fill_missing_street_and_city(formatted_address)
    fill_missing_county unless address[:county]

    address
  end

  private

  def parse_address_components(acs)
    map_address_attributes(acs)
    @address[:state] = address[:state_code]
    @address[:city] ||= address[:sublocality]
    @address[:line1] = build_line1
  end

  def map_address_attributes(acs)
    attrs     = %w(street_number route locality sublocality
                   administrative_area_level_1 postal_code)
    attrs_map = %i(street_number street city sublocality
                   state_code zip)

    acs.each do |d|
      t = d['types'][0]
      ind = attrs.index(t)
      next unless ind
      @address[attrs_map[ind]] = d[SHORT_NAME] if t != 'locality'
      @address[attrs_map[ind]] = d[LONG_NAME] if t == 'locality'
    end
  end

  def fill_missing_street_and_city(formatted_address)
    return unless formatted_address

    parse_formatted_address(formatted_address) unless address[:city]

    return unless address[:line1].blank? && address[:city]
    fill_missing_line1(formatted_address)
  end

  def fill_missing_line1(formatted_address)
    address_parts = formatted_address.split(',')

    return unless address_parts[1] && address_parts[1].squish == address[:city]
    @address[:line1] = address_parts[0]
  end

  def fill_missing_county
    return unless address[:city] && address[:state]
    city_state = "#{address[:city]},#{address[:state]}".downcase
    city_result = GeoServices.findcity(city_state, address[:zip])
    @address[:county] = city_result && city_result.county_name
  end

  def parse_formatted_address(fa)
    searchres = GeoServices.perform_search(fa)
    return if searchres.size == 0

    gs = searchres[0]
    return unless gs.country_code == 'US'

    map_google_service_address(gs)

    find_city_from_zip

    find_county_from_city_state

    ensure_county_in_state
  end

  def map_google_service_address(gs)
    @address[:line1] = gs.street_address
    @address[:city]  = gs.city
    @address[:state] = gs.state_code
    @address[:zip]   = gs.postal_code

    county_component = gs.address_components_of_type('administrative_area_level_2')
    valid_county = county_component && county_component[0]
    @address[:county] = county_component[0][LONG_NAME] if valid_county
  end

  def find_city_from_zip
    return unless address[:zip] && !address[:city]
    city = City.where(zip: address[:zip]).first

    return unless city
    @address[:city] = city.name
    @address[:county] = city.county_name
  end

  def find_county_from_city_state
    return if address[:county]
    return unless address[:city] && address[:state]
    fill_county_from_city_state_zip
  end

  def fill_county_from_city_state_zip
    city = GeoServices.findcity("#{address[:city]},#{address[:state]}", address[:zip])
    @address[:county] = city && city.county_name
  end

  # if county name is found, then make sure it is in the state
  def ensure_county_in_state
    return unless address[:county]
    state = State.check_and_get(address[:state])
    county = state && state.get_county(address[:county])
    @address[:county] = nil unless county
  end

  def build_line1
    return nil unless address[:street] && address[:street_number]
    address[:street_number] + ' ' + address[:street]
  end
end
