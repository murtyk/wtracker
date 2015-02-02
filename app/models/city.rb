# a city in usa.
# part of a county.
class City < ActiveRecord::Base
  belongs_to :state
  belongs_to :county

  attr_accessible :county_id, :city_state, :latitude,
                  :longitude, :name, :state_code, :zip

  validates :state_code, presence: true, length: { minimum: 2, maximum: 2 }
  validates :city_state, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :name, presence: true

  def county_name
    county.name
  end

  def in_state?(s)
    s && state && s.squish.downcase == state.code.downcase
  end

  def state_code
    state.code
  end

  def self.search(name, state_id)
    return [] if state_id == 0 && name.blank?
    if state_id > 0
      cities = State.find(state_id).cities
      return cities.where('name ilike ?', name + '%') unless name.blank?
      return cities
    end
    return where('name ilike ?', name + '%') unless name.blank?
  end

  def self.get_by_citystate(city_state)
    where('city_state ilike ?', city_state.squish).first
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
end
