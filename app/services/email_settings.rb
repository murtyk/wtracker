# email settings from trainees and users
class EmailSettings
  JOB_LEADS_SETTINGS = {
    enable_starttls_auto: false,
    ssl: true,
    tls: false,
    address: 'server201.web-hosting.com',
    port: 465,
    domain: 'operoinc.com',
    authentication: :login,
    user_name: ENV['AUTOLEAD_EMAIL_USERNAME'],
    password: ENV['AUTOLEAD_EMAIL_PASSWORD']
  }

  STANDARD_SETTINGS = {
    enable_starttls_auto: true,
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'opero.com',
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
