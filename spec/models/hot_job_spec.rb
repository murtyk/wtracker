require 'rails_helper'

RSpec.describe HotJob, type: :model do
  let(:employer) { FactoryGirl.create(:employer, account_id: 1) }

  it 'has a valid factory' do
    expect(FactoryGirl.create(:hot_job, employer_id: employer.id)).to be_valid
  end
  it 'is invalid without a closing date' do
    expect(FactoryGirl.build(:hot_job, closing_date: nil)).to_not be_valid
  end
end
