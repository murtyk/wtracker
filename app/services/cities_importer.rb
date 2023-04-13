# frozen_string_literal: true

include UtilitiesHelper

CITY_FIELDS = %w[zip city state county latitude longitude].freeze
# imports cities from a file
class CitiesImporter < Importer
  attr_reader :cities

  def initialize(all_params = nil, current_user = nil)
    return unless all_params

    file_name = all_params[:file].original_filename
    @import_status = CityImportStatus.create(user_id: nil, file_name: file_name)
    super
  end

  def header_fields
    CITY_FIELDS
  end

  def cities
    @objects || []
  end

  private

  def import_row(row)
    lng, lat           = coordinates(row)
    zip, county, state = zip_county_state(row)

    fail_on_duplicate_city(row['city'], state.code, zip)

    city = new_city(state, row['city'], lat, lng, zip)
    county        ||= findcounty(city, state)
    city.county_id  = county.id if county
    city.save!

    city
  end

  def new_city(state, name, lat, lng, zip)
    city            = state.cities.new
    city.name       = name
    city.zip        = zip
    city.longitude  = lng
    city.latitude   = lat
    city
  end

  def coordinates(row)
    raise 'invalid longitude' unless valid_float row['longitude']
    raise 'invalid latitude' unless valid_float row['latitude']

    [row['longitude'].to_f, row['latitude'].to_f]
  end

  def zip_county_state(row)
    zip = clean_zip_code(row['zip'])

    state = valid_state(row)

    county = clean_county(row, state)

    [zip, county, state]
  end

  def clean_zip_code(zip)
    zip = zip.to_i.to_s
    raise 'invalid zip code' if zip.size < 4

    zip = "0#{zip}" if zip.size < 5
    zip
  end

  def valid_state(row)
    state = State.check_and_get(row['state'])
    return state if state

    raise "state does not exist #{row['state']}"
  end

  def clean_county(row, state)
    return nil if row['county'].blank?

    county = state.get_county(row['county'].downcase.gsub(' county', ''))
    return county if county

    fail_county_not_found(row['county'], state.code)
  end

  def fail_on_duplicate_city(city_name, state_code, zip)
    predicate = 'name ilike ? and state_code ilike ? and zip = ?'
    return unless City.where(predicate, city_name, state_code, zip).first

    raise "city already exists #{city_name},#{state_code}"
  end

  def findcounty(city, state)
    latlong = "#{city.latitude},#{city.longitude}"
    county_name = GeoServices.findcounty(latlong)
    city_state_zip = " #{city.name},#{state.code},#{city.zip}"
    raise "county not found for #{city_state_zip}" unless county_name

    county = state.get_county(county_name)
    return county if county

    fail_county_not_found(county_name, state.code)
  end

  def fail_county_not_found(county_name, state_code)
    raise "county #{county_name} not found in state #{state_code}"
  end
end
