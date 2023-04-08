# frozen_string_literal: true

require 'rails_helper'

describe AdminMailer do
  describe 'notify_applicant_missing' do
    let(:user) { create(:user, role: 1) }

    before :each do
      Delayed::Worker.delay_jobs = false

      @account = Account.where(subdomain: 'apple').first
      Account.current_id = @account.id
      @grant = Grant.where(name: 'Right To Work').first
      Grant.current_id = @grant.id

      allow_any_instance_of(Applicant).to receive(:humanizer_questions)
        .and_return([{ 'question' => 'Two plus two?',
                       'answers' => %w[4 four] }])

      generate_applicants(1)

      @applicant = Applicant.last

      @trainee = @applicant.trainee

      @trainee.email

      @applicant.update(trainee_id: nil)

      @tas = TraineeAdvancedSearch.new(user)

      @tas.build_document({})
    end

    it 'sends an email to app admin' do
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eql('Applicant Missing')
    end
  end
end
