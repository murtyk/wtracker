require 'rails_helper'

RSpec.describe Employer, type: :model do
  before :each do
    Account.current_id = 1
  end
  it 'has a valid factory' do
    expect(FactoryGirl.create(:employer)).to be_valid
  end
  it 'is invalid without a name' do
    expect(FactoryGirl.build(:employer, name: nil)).to_not be_valid
  end
  # it "is invalid without a source" do
  pending 'implement this after doing validation on employer_source_id'
  # end
  it "returns a employer's name as a string" do
    employer = FactoryGirl.create(:employer, name: 'ABC Inc.')
    expect(employer.name).to eq('ABC Inc.')
  end
end
