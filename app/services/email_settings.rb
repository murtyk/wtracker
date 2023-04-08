# frozen_string_literal: true

# email settings from trainees and users
class EmailSettings
  SES_SETTINGS = {
    address: ENV['SES_ADDRESS'],
    port: 465,
    user_name: ENV['SES_SMTP_USER_NAME'],
    password: ENV['SES_SMTP_PASSWORD'],
    authentication: :plain,
    ssl: true   # For TLS SSL connection
  }.freeze

  COMMON_SMTP_SETTINGS = {
    enable_starttls_auto: true,
    address: 'smtp.gmail.com',
    port: 587,
    domain: "#{ENV['DOMAIN']}.com",
    authentication: :login
  }.freeze

  class << self
    def use_ses
      ActionMailer::Base.smtp_settings = SES_SETTINGS
    end
  end
end
