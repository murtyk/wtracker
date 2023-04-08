# frozen_string_literal: true

require 'rails_helper'

describe Klass do
  before :each do
    Account.current_id = 1
    Grant.current_id = 1
  end
  it 'has a valid factory' do
    expect(FactoryBot.create(:klass)).to be_valid
  end
  it 'is invalid without name' do
    expect(FactoryBot.build(:klass, name: nil)).to_not be_valid
  end
  it 'is invalid without start date year < 2000' do
    expect(FactoryBot.build(:klass, start_date: '12/01/1998')).to_not be_valid
  end
  it 'is invalid without end date year < 2000' do
    expect(FactoryBot.build(:klass, end_date: '12/01/1998')).to_not be_valid
  end
  it 'is valid with start date year > 2000' do
    expect(FactoryBot.build(:klass, start_date: '12/01/2016')).to be_valid
  end
  it 'is valid with end date year > 2000' do
    expect(FactoryBot.build(:klass, end_date: '12/01/2012')).to be_valid
  end
end
