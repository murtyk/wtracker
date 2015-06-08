require 'rails_helper'

RSpec.describe Api::V1::LeadsQueuesController, type: :controller do
  describe 'GET #show' do
    before(:each) do
      admin = FactoryGirl.create :admin
      api_authorization_header admin.auth_token
      @lead_queue = FactoryGirl.create :leads_queue
      request.host = 'operoapi.localhost.com'
      get :show, id: 1
    end

    it 'returns the information about a lead job on a hash' do
      expect(json_response[:data][:skills]).to eql @lead_queue.skills
    end

    it { is_expected.to respond_with 200 }
  end
end
