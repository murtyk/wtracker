require 'rails_helper'

describe TraineeAutoLeads do
  let(:account_id) { Account.find_by(subdomain: 'njit').id }
  let(:grant_id) { Grant.first.id }

  let(:trainee) { create(:trainee, status: 0) }
  let(:jsp) { create(:job_search_profile, trainee_id: trainee.id) }
  let(:agent) do
    create(:agent, identifiable_type: 'Trainee', identifiable_id: trainee.id)
  end

  before :each do
    Account.current_id = account_id
    Grant.current_id = grant_id
    jsp
    agent
  end

  it 'sends jobs leads to trainee' do
    allow(AutoMailer).to receive(:send_job_leads) do |args|
      expect(args.first.trainee_id).to be(trainee.id)
    end
    VCR.use_cassette('trainee_auto_leads') do
      TraineeAutoLeads.perform(account_id, grant_id, trainee.id)

      key = "g#{grant_id}_#{trainee.id}"
      count = Rails.cache.read(key)
      expect(count).to eql(25)
    end
  end
end
