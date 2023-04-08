require 'rails_helper'

describe City do
  it 'has a valid factory' do
    expect(FactoryBot.create(:city)).to be_valid
  end
  it 'is invalid with wrong county and state' do
    expect(FactoryBot.build(:city, state_id: 99_999)).to_not be_valid
    expect(FactoryBot.build(:city, county_id: 99_999)).to_not be_valid
  end
  it 'returns correct values' do
    nj = State.find_by(code: 'NJ')
    county = nj.counties.first
    city = FactoryBot.create(:city, state_id: nj.id, county_id: county.id)
    expect(city.county_name).to eq(county.name)
    expect(city.state_code).to eq('NJ')
    expect(city.city_state).to eq(city.name + ',NJ')
  end
end
