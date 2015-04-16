require 'rails_helper'

RSpec.describe KlassTraineesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Organization. As you add validations to Organization, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OrganizationsController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  describe 'new' do
    login_user
    before :each do
      allow(Account).to receive(:find_by_subdomain!)
        .and_return(Account.find(1))
      Account.current_id = 1
      Grant.current_id = 1
    end
    it 'assigns @trainees and @klasses_collection when passed trainee_ids' do
      xhr :get, :new, { trainee_ids: '' }, valid_session
      expect(assigns(:trainees)).not_to be_nil
      expect(assigns(:klasses_collection)).not_to be_nil

      expect(assigns(:klass)).to be_nil
    end
    it 'assigns @trainee and @klass_trainee when passed trainee_id' do
      xhr :get, :new, { trainee_id: 1 }, valid_session

      expect(assigns(:trainees)).to be_nil

      expect(assigns(:klass_trainee)).not_to be_nil
    end
    it 'assigns @klass and @klass_trainee when passed klass_id' do
      xhr :get, :new, { klass_id: 1 }, valid_session

      expect(assigns(:trainee)).to be_nil
      expect(assigns(:trainees)).to be_nil

      expect(assigns(:klass_trainee)).not_to be_nil
    end
  end
end
