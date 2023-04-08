# frozen_string_literal: true

require 'rails_helper'

def create_trainees_and_profies
  2.times do |n|
    first = "first#{n}"
    t = Trainee.create(first: first, last: 'last', email: "#{first}@nomail.net")
    jsp_attrs = { skills: 'java ruby ajax', location: 'East Windsor,NJ', distance: 20 }
    t.create_job_search_profile(jsp_attrs)
  end
  2.times do |n|
    first = "first#{n + 2}"
    t = Trainee.create(first: first, last: 'last', email: "#{first}@nomail.net")
    jsp_attrs = { skills: 'java xml swing j2ee',
                  location: 'East Windsor,NJ',
                  distance: 20 }
    t.create_job_search_profile(jsp_attrs)
  end
end

RSpec.describe TraineesController, type: :controller do
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
    login_user('njit@mail.com')
    before :each do
      allow(Account).to receive(:find_by_subdomain!)
        .and_return(Account.find_by(subdomain: 'njit'))
      Account.current_id = Account.find_by(subdomain: 'njit').id
      Grant.current_id = Grant.first.id
      create_trainees_and_profies
    end
    it 'assigns @results when searched by skills' do
      get :search_by_skills, { filters: { skills: 'ruby' } }, valid_session
      expect(assigns(:results)).not_to be_nil
      expect(assigns(:trainee_email)).not_to be_nil
    end
    it 'assigns @trainees when searched(index) last name' do
      get :index, { filters: { last_name: 'last' } }, valid_session
      expect(assigns(:trainees)).not_to be_nil
    end
  end
end
