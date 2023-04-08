# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JobSearchProfilesController, type: :controller do
  def create_trainees_and_profies
    jsp_attrs = { account_id: Account.current_id }
    2.times do |n|
      first = "first#{n}"
      t = Trainee.create(first: first, last: 'last', email: "#{first}@nomail.net")
      t.create_job_search_profile(jsp_attrs)
    end
  end

  let(:valid_session) { {} }

  describe 'remind' do
    login_user('njit@mail.com')
    before :each do
      allow(Account).to receive(:find_by_subdomain!)
        .and_return(Account.find_by(subdomain: 'njit'))
      Account.current_id = Account.find_by(subdomain: 'njit').id
      Grant.current_id = Grant.first.id
      create_trainees_and_profies
    end
    it 'sends reminders' do
      Delayed::Worker.delay_jobs = false
      expect { get :remind, {}, valid_session }.to change {
        ActionMailer::Base.deliveries.count
      }.by(2)
      get :remind, {}, valid_session
      expect(assigns(:trainees)).not_to be_nil
    end
  end
end
