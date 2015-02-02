require 'rails_helper'

describe Trainee do
  before :each do
    Account.current_id = 1
    Grant.current_id = 1
  end
  it "has a valid factory" do
    expect(FactoryGirl.create(:trainee)).to be_valid
  end
  it "is invalid without a first name" do
    expect(FactoryGirl.build(:trainee, first: nil)).to_not be_valid
  end
  it "is invalid without a last name" do
    expect(FactoryGirl.build(:trainee, last: nil)).to_not be_valid
  end

  it "returns a trainee's full name as a string" do
    trainee = FactoryGirl.create(:trainee, first: "John", last: "Doe")
    expect(trainee.name).to eq("John Doe")
  end

end