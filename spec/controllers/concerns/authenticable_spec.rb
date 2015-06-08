require 'rails_helper'

class Authentication  < ActionController::Base
  include Authenticable
end

describe Authenticable, type: :controller do
  let(:authentication) { Authentication.new }

  describe '#current_admin' do
    before do
      @admin = FactoryGirl.create :admin
      request.headers['Authorization'] = @admin.auth_token
      allow(authentication).to receive(:request).and_return(request)
    end
    it 'returns the admin from the authorization header' do
      expect(authentication.current_admin.auth_token).to eql @admin.auth_token
    end
  end

  describe '#authenticate_with_token' do
    before do
      allow(authentication).to receive(:current_admin).and_return(nil)
      allow(authentication).to receive(:render) do |args|
        args
      end
    end

    it 'returns error' do
      errors = authentication.authenticate_with_token![:json][:errors]
      expect(errors).to eq 'Not authenticated'
    end

    it 'returns unauthorized status' do
      expect(authentication.authenticate_with_token![:status]).to eq :unauthorized
    end
  end

  describe '#admin_signed_in?' do
    context "when there is a admin on 'session'" do
      before do
        @admin = FactoryGirl.create :admin
        allow(authentication).to receive(:current_admin).and_return(@admin)
      end

      it { expect(authentication.admin_signed_in?).to be_truthy }
    end

    context "when there is no admin on 'session'" do
      before do
        @admin = FactoryGirl.create :admin
        allow(authentication).to receive(:current_admin).and_return(nil)
      end

      it { expect(authentication.admin_signed_in?).to_not be_truthy }
    end
  end
end
