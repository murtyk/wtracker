# email settings from trainees and users
class EmailSettings
  JOB_LEADS_SETTINGS = {
    enable_starttls_auto: true,
    address: 'smtp.gmail.com',
    port: 587,
    domain: "#{ENV['DOMAIN']}.com",
    authentication: :login,
    user_name: ENV['AUTOLEAD_EMAIL_USERNAME'],
    password: ENV['AUTOLEAD_EMAIL_PASSWORD']
  }

  STANDARD_SETTINGS = {
    enable_starttls_auto: true,
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'wtracker.com',
    authentication: :login,
    user_name: ENV['GMAIL_USER_NAME'],
    password: ENV['GMAIL_PASSWORD']
  }

  def self.use_job_leads_email
    ActionMailer::Base.smtp_settings = JOB_LEADS_SETTINGS
  end
  def self.use_standard_email
    ActionMailer::Base.smtp_settings = STANDARD_SETTINGS
  end
end
