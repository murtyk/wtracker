# email settings from trainees and users
class EmailSettings
  SES_SETTINGS = {
    :address              => ENV['SES_ADDRESS'],
    :port                 => 465,
    :user_name            => ENV['SES_SMTP_USER_NAME'],
    :password             => ENV['SES_SMTP_PASSWORD'],
    :authentication       => :plain,
    :ssl                  => true   #For TLS SSL connection
  }

  COMMON_SMTP_SETTINGS = {
    enable_starttls_auto: true,
    address: 'smtp.gmail.com',
    port: 587,
    domain: "#{ENV['DOMAIN']}.com",
    authentication: :login,
  }

  AUTOLEADS_SETTINGS = {
    password: ENV['AUTOLEAD_EMAIL_PASSWORD']
  }

  # JOB_LEADS_SETTINGS = {
  #   user_name: ENV['AUTOLEAD_EMAIL_USERNAME'],
  #   password: ENV['AUTOLEAD_EMAIL_PASSWORD']
  # }

  STANDARD_SETTINGS = {
    user_name: ENV['GMAIL_USER_NAME'],
    password: ENV['GMAIL_PASSWORD']
  }

  SUPPORT_SETTINGS = {
    user_name: ENV['SUPPORT_FROM_EMAIL'],
    password: ENV['SUPPORT_EMAIL_PASSWORD']
  }

  class << self

  def use_ses
    ActionMailer::Base.smtp_settings = SES_SETTINGS
  end

  def auto_leads_from_email(lead_number)
    # index = lead_number % auto_leads_emails_count
    # auto_leads_emails[index]

    ENV['GMAIL_USER_NAME']
  end

  def auto_leads_emails
    @auto_leads_emails ||= ENV['AUTOLEAD_FROM_EMAILS'].split(",")
  end

  def auto_leads_emails_count
    @auto_leads_emails_count ||= auto_leads_emails.size
  end

  end
end
