# frozen_string_literal: true

require 'rails_helper'

describe Trainee do
  before :each do
    Account.current_id = 1
    Grant.current_id = 1
  end
  it 'has a valid factory' do
    expect(FactoryBot.create(:trainee)).to be_valid
  end
  it 'is invalid without a first name' do
    expect(FactoryBot.build(:trainee, first: nil)).to_not be_valid
  end
  it 'is invalid without a last name' do
    expect(FactoryBot.build(:trainee, last: nil)).to_not be_valid
  end

  it "returns a trainee's full name as a string" do
    trainee = FactoryBot.create(:trainee, first: 'John', last: 'Doe')
    expect(trainee.name).to eq('John Doe')
  end

  describe 'when email bounced' do
    let(:trainee) { FactoryBot.create(:trainee, bounced: true) }
    it 'valid_email? returns false' do
      expect(trainee.valid_email?).not_to be_truthy
    end
  end
end
