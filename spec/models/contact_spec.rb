require 'rails_helper'

describe Contact do
  before :each do
    Account.current_id = 1
  end
  it 'has a valid factory' do
    expect(FactoryGirl.create(:contact)).to be_valid
  end
  it 'is invalid without a first name' do
    expect(FactoryGirl.build(:contact, first: nil)).to_not be_valid
  end
  it 'is invalid without a last name' do
    expect(FactoryGirl.build(:contact, last: nil)).to_not be_valid
  end
  it ' adds contacts to an employer' do
    employer = FactoryGirl.create(:employer)
    attrs    = FactoryGirl.attributes_for(:contact, first: 'Roger', last: 'Fed')
    contact  = employer.contacts.create(attrs)
    expect(contact.name).to eq('Roger Fed')
  end
end
