require 'faker'

def fake_address
  {
    line1:     Faker::Address.street_address,
    city:      Faker::Address.city,
    state:     Faker::Address.state_abbr,
    zip:       Faker::Address.zip,
    longitude: Faker::Address.longitude,
    latitude:  Faker::Address.latitude,
    county_id: 1,
    county:    'mycounty'
  }
end
