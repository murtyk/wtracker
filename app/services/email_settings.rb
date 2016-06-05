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

  class << self

  def use_job_leads_email(num = 1)
    from_email = job_leads_from_email(num)

    ActionMailer::Base.smtp_settings = JOB_LEADS_SETTINGS.merge(user_name: from_email)
  end

  def job_leads_from_email(num)
    if num < 2 || extra_leads_emails_count == 0
      return ENV['AUTOLEAD_EMAIL_USERNAME']
    end

    leads_extra_emails_list[num - 2] # extra emails start when num >= 2
  end

  def use_standard_email
    ActionMailer::Base.smtp_settings = STANDARD_SETTINGS
  end

  def extra_leads_emails_count
    ENV['AUTOLEAD_EXTRA_FROM_EMAILS'].to_i
  end

  def leads_extra_emails_list
    @leads_extra_emails_list ||= build_leads_extra_emails
  end

  def leads_email
    @leads_email ||= ENV['AUTOLEAD_EMAIL_USERNAME']
  end

  # this should generate a list [support1@operoinc.com, support2@operoinc.com, ....]
  def build_leads_extra_emails
    prefix, domain = leads_email.split("@")
    (1..extra_leads_emails_count).map{ |n| prefix + n.to_s + "@" + domain }
  end

  end
end
