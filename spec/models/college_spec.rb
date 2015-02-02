require 'rails_helper'

describe College do
  before :each do
    Account.current_id = 1
  end
  it "has a valid factory" do
    expect(FactoryGirl.create(:college)).to be_valid
  end
  it "is invalid without a name" do
    expect(FactoryGirl.build(:college, name: nil)).to_not be_valid
  end
  it "returns college name as a string " do
    college = FactoryGirl.create(:college, name: 'College1')
    college.create_address(FactoryGirl.attributes_for(:address))
    expect(college.name).to eq("College1")
  end
end