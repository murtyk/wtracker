# frozen_string_literal: true

require 'rails_helper'

describe QueueAutoLeadsJobs do
  let(:t1) { create(:trainee, status: 4) }

  let(:t2) { create(:trainee, status: 0) } # not placed, opted out
  let(:jsp2) { create(:job_search_profile, trainee_id: t2.id, opted_out: true) }

  let(:t3) { create(:trainee, status: 0) } # not placed
  let(:jsp3) { create(:job_search_profile, trainee_id: t3.id) } # valid profile

  let(:t4) { create(:trainee, status: 0) } # not placed
  let(:jsp4) { create(:job_search_profile, trainee_id: t4.id) } # valid profile

  let(:t5) { create(:trainee, status: 0) } # not placed

  let(:city) { create(:city, name: 'Edison', state_code: 'NJ') }

  before :each do
    account = Account.find_by(subdomain: 'njit')
    Account.current_id = account.id
    Grant.current_id = Grant.first.id

    allow(GeoServices).to receive(:findcity).and_return(city)

    t1
    jsp2
    jsp3
    jsp4
    t5
  end

  it 'queues a job for sending leads' do
    Delayed::Worker.delay_jobs = true

    allow_any_instance_of(QueueAutoLeadsJobs).to receive(:grants_for_auto_leads)
      .and_return([Grant.find(Grant.current_id)])

    QueueAutoLeadsJobs.perform
    expect(Delayed::Job.count).to eq(3)

    job = Delayed::Job.first
    expect(job.handler.include?('TraineeAutoLeads')).to be_truthy

    job = Delayed::Job.last
    expect(job.handler.include?('GrantAutoLeadsStatus')).to be_truthy
  end
end
