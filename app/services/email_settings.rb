# email settings from trainees and users
class EmailSettings
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

  def use_auto_leads_email(lead_number = 0)
    from_email = auto_leads_from_email(lead_number)

    change_smtp_settings(AUTOLEADS_SETTINGS.merge(user_name: from_email))
  end

  def use_job_leads_email(num = 1)
    use_auto_leads_email(num)
  end

  def use_standard_email
    change_smtp_settings(STANDARD_SETTINGS)
  end

  def use_support_email
    change_smtp_settings(SUPPORT_SETTINGS)
  end

  def change_smtp_settings(settings)
    ActionMailer::Base.smtp_settings = COMMON_SMTP_SETTINGS.merge(settings)
  end

  def auto_leads_from_email(lead_number)
    index = lead_number % auto_leads_emails_count
    auto_leads_emails[index]
  end

  def auto_leads_emails
    @auto_leads_emails ||= ENV['AUTOLEAD_FROM_EMAILS'].split(",")
  end

  def auto_leads_emails_count
    @auto_leads_emails_count ||= auto_leads_emails.size
  end

  end
end
