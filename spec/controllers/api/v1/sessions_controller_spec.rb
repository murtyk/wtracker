require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  describe 'POST #create' do
    before(:each) do
      request.host = 'operoapi.localhost.com'
      @admin = FactoryGirl.create :admin
      include_default_accept_headers
    end

    context 'when the credentials are correct' do
      before(:each) do
        credentials = { email: @admin.email, password: '12345678' }
        post :create, session: credentials
      end

      it 'returns the admin record corresponding to the given credentials' do
        @admin.reload
        # expect(json_response[:admin][:auth_token]).to eql @admin.auth_token
        expect(json_response[:auth_token]).to eql @admin.auth_token
      end

      it { is_expected.to respond_with 200 }
    end

    context 'when the credentials are incorrect' do
      before(:each) do
        credentials = { email: @admin.email, password: 'invalidpassword' }
        post :create, session: credentials
      end

      it 'returns a json with an error' do
        expect(json_response[:errors]).to eql 'Invalid email or password'
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      request.host = 'operoapi.localhost.com'
      @admin = FactoryGirl.create :admin
      sign_in @admin
      @admin.generate_authentication_token!
      @admin.save
      delete :destroy, id: @admin.auth_token
    end

    it { is_expected.to respond_with 204 }
  end
end
