# frozen_string_literal: true

# a company found through google places search
class GoogleCompany
  alias_attribute(:city, :city_name)
  attr_reader :name, :website, :types, :score, :formatted_address,
              :line1, :city_name, :sublocality, :state_code, :zip, :county,
              :latitude, :longitude, :phone_no, :source

  def initialize(json)
    @souce              = 'GP'
    @name               = json['name']
    @website            = json['website'] && URI.parse(json['website']).host
    @types              = json['types'].join(',')
    @formatted_address  = json['formatted_address']
    @score              = json[:score]
    @phone_no           = json['formatted_phone_number']

    init_coordinates(json)
    init_address_attributes(json)
  end

  def init_coordinates(json)
    @latitude    = json['geometry']['location']['lat']
    @longitude   = json['geometry']['location']['lng']
  end

  def init_address_attributes(json)
    @line1       = json[:line1]
    @city_name   = json[:city]
    @state_code  = json[:state]
    @zip         = json[:zip]
    @county      = json[:county]
  end

  def info_for_add
    {
      name: @name,
      latitude: @latitude,
      longitude: @longitude,
      phone_no: @phone_no,
      website: @website,
      line1: @line1,
      city: @city_name,
      state_code: @state_code,
      zip: @zip
    }
  end

  def state
    State.check_and_get(state_code)
  end

  def state_id
    state.id
  end

  def county_id
    state.get_county(county).id
  end
end
