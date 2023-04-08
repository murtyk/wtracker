# frozen_string_literal: true

require 'rails_helper'

describe AutoLeadsJob do
  let(:city) { create(:city, name: 'Edison', state_code: 'NJ') }
  before :each do
    account = Account.find_by(subdomain: 'njit')
    Account.current_id = account.id
    Grant.current_id = Grant.first.id

    allow(GeoServices).to receive(:findcity).and_return(city)

    trainee = FactoryBot.create :trainee
    @jsp_attr = FactoryBot.attributes_for :job_search_profile
    trainee.create_job_search_profile @jsp_attr

    alj = AutoLeadsJob.new
    allow(alj).to receive(:queue_leads_job_on_workers).and_return(nil)
    alj.perform
  end

  it 'fills queue with jobs' do
    expect(LeadsQueue.first.skills).to eql(@jsp_attr[:skills])
  end
end
