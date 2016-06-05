require 'rails_helper'

describe EmailSettings do
  before do
    ENV['AUTOLEAD_EXTRA_FROM_EMAILS'] = '3'
    ENV['AUTOLEAD_EMAIL_USERNAME'] = "support@mydomain.com"

    @emails = ["support@mydomain.com", "support1@mydomain.com", "support2@mydomain.com"]
  end

  it "returns correct support email" do
    expect(EmailSettings.job_leads_from_email(0)).to eql(@emails[0])
    expect(EmailSettings.job_leads_from_email(1)).to eql(@emails[0])

    expect(EmailSettings.job_leads_from_email(2)).to eql(@emails[1])
    expect(EmailSettings.job_leads_from_email(3)).to eql(@emails[2])
  end
end
