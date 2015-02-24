# a city in usa.
# part of a county and a state
class City < ActiveRecord::Base
  attr_accessible :name, :latitude, :longitude, :county_id, :zip

  belongs_to :state
  belongs_to :county
  delegate :county_name, to: :county, allow_nil: true

  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :name, presence: true

  validate :validate_state_and_county

  before_save :determine_city_state

  # checks if this city is in a state (state code)
  def in_state?(s)
    s && state && s.squish.downcase == state.code.downcase
  end

  def self.search(name, state_id)
    return [] if state_id.to_i == 0 && name.blank?
    cities = City
    cities = cities.where(state_id: state_id) if state_id.to_i > 0
    name.blank? ? cities : cities.where('name ilike ?', name + '%')
  end

  def self.find_by_citystate(city_comma_state)
    city_name, st_code = city_comma_state.split(',')
    return nil unless city_name && st_code
    find_by('city_state ilike ?', city_name.squish + ',' + st_code.squish)
  end

  # find_by_zip might be useful in future. For now, we do not
  # want to add cities when seareched by zip.
  # def self.find_by_zip(zip)
  #   city = City.where(zip: zip).first
  #   return city if city

  #   #city does not exist in the db. can we add?
  #   results = GeoServices.perform_search(zip)
  #   return nil unless results && results[0] && results[0].postal_code == zip
  #   state_name = results[0].state
  #   state = State.where('name ilike ?', state_name).first
  #   return nil unless state
  #   name = results[0].city
  #   latitude = results[0].latitude
  #   longitude = results[0].longitude
  #   county = County.find_by_city_and_state(name, state.code)
  #   city = state.cities.new(name: name, zip: zip, county_id: county.id,
  # latitude: latitude, longitude: longitude)
  #   city.save
  #   city
  # end

  private

  def validate_state_and_county
    return false unless state_id && county_id

    s = State.where(id: state_id).first
    errors.add(:state_id, 'invalid state id') unless s

    c = County.where(id: county_id).first
    errors.add(:county_id, 'invalid county id') unless c

    errors.add(:county_id, 'county not in given state') unless c && c.state == s

    s && c && c.state == s
  end

  def determine_city_state
    self.state_code ||= state.code
    self.city_state ||= name + ',' + state_code
  end
end
