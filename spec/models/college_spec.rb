require 'rails_helper'

describe College do
  before :each do
    Account.current_id = 1
  end
  it 'has a valid factory' do
    expect(FactoryBot.create(:college)).to be_valid
  end
  it 'is invalid without a name' do
    expect(FactoryBot.build(:college, name: nil)).to_not be_valid
  end
  it 'returns college name as a string ' do
    college = FactoryBot.create(:college, name: 'College1')
    college.create_address(FactoryBot.attributes_for(:address))
    expect(college.name).to eq('College1')
  end
end
