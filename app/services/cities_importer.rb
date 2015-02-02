include UtilitiesHelper

CITY_FIELDS = %w(zip city state county latitude longitude)
# imports cities from a file
class CitiesImporter < Importer
  attr_reader :cities

  def initialize(all_params = nil, current_user = nil)
    if all_params
      file_name = all_params[:file].original_filename
      @import_status = CityImportStatus.create(user_id: nil, file_name: file_name)
      super
    end
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

    if city_exists?(row['city'], state.code, zip)
      fail "city already exists #{row['city']},#{state.code}"
    end

    city            = state.cities.new
    city.name       = row['city']
    city.zip        = zip
    city.state_code = state.code
    city.city_state = (city.name + ',' + state.code).downcase
    city.longitude  = lng
    city.latitude   = lat
    county        ||= findcounty(city, state)
    city.county_id  = county.id if county
    city.save!

    city
  end

  def coordinates(row)
    fail 'invalid longitude' unless valid_float row['longitude']
    fail 'invalid latitude' unless valid_float row['latitude']
    [row['longitude'].to_f, row['latitude'].to_f]
  end

  def city_exists?(city_name, state_code, zip)
    predicate = 'name ilike ? and state_code ilike ? and zip = ?'
    City.where(predicate, city_name, state_code, zip).first
  end

  def zip_county_state(row)
    fail 'invalid longitude' unless valid_float row['longitude']
    fail 'invalid latitude' unless valid_float row['latitude']

    zip = clean_zip_code(row['zip'])

    state = State.check_and_get(row['state'])
    fail "state does not exist #{row['state']}" unless state

    unless row['county'].blank?
      county = state.get_county(row['county'].downcase.gsub(' county', ''))
      fail "county #{row['county']} not found in state #{state.code}" unless county
    end

    [zip, county, state]
  end

  def clean_zip_code(zip)
    zip = zip.to_i.to_s
    fail 'invalid zip code' if zip.size < 4
    zip = '0' + zip if zip.size < 5
    zip
  end

  def findcounty(city, state)
    latlong = city.latitude.to_s + ',' + city.longitude.to_s
    county_name = GeoServices.findcounty(latlong)
    city_state_zip = " #{city.name},#{state.code},#{city.zip}"
    fail "county not found for #{city_state_zip}" unless county_name
    county = state.get_county(county_name)
    fail "county #{county_name} not found in #{state.code}" unless county
    county
  end
end
