require 'rails_helper'

describe EmailSettings do
  before do
    @emails = ENV['AUTOLEAD_FROM_EMAILS'].split(",")
  end

  it "returns correct support emails" do
    expect(EmailSettings.auto_leads_emails[0]).to eql(@emails[0])
    expect(EmailSettings.auto_leads_emails[1]).to eql(@emails[1])
    expect(EmailSettings.auto_leads_emails[2]).to eql(@emails[2])
  end

  it "uses auto leads from emails in round robin" do
    count = @emails.count
    n = rand(5..15)
    lead_start = count * n
    lead_end = count * (n + 1) - 1

    index = 0

    (lead_start..lead_end).each do |lead_number|
      EmailSettings.use_auto_leads_email(lead_number)
      expect(ActionMailer::Base.smtp_settings[:user_name]).to eql(@emails[index])
      index += 1
    end
  end
end
