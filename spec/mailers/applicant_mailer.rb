# frozen_string_literal: true

require 'rails_helper'

describe ApplicantMailer do
  describe 'notify_applicant_status' do
    before :each do
      @account = Account.where(subdomain: 'apple').first
      Account.current_id = @account.id
      @grant = Grant.where(name: 'Right To Work').first
      Grant.current_id = @grant.id

      @accepted_es = EmploymentStatus.where(action: 'Accepted').first
      @declined_es = EmploymentStatus.where(action: 'Declined').first

      @applicant = double(Applicant,
                          account: @account,
                          grant: @grant,
                          email_subject: @accepted_es.email_subject,
                          email_body: @accepted_es.email_body,
                          accepted?: true,
                          first_name: 'Lucas',
                          last_name: 'Caton',
                          name: 'Lucas Caton',
                          email: 'mkorada@jobpadhq.com',
                          login_id: 'Lucas_Caton',
                          reapply_key: nil)
    end

    it 'reply_to should be admins email' do
      mail = ApplicantMailer.notify_applicant_status(@applicant).deliver_now
      expect(mail.reply_to).to eql([@account.admins.first.email])
      mail.deliver
    end

    it 'reply_to should be grant reply to email' do
      @grant.reply_to_email = 'rtw@nomail.com'
      mail = ApplicantMailer.notify_applicant_status(@applicant).deliver_now
      expect(mail.reply_to).to eql([@applicant.grant.reply_to_email])
    end
  end
end
