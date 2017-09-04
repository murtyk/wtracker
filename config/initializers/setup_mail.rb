ActionMailer::Base.smtp_settings = {
  :address              => ENV['SES_ADDRESS'],
  :port                 => 465,
  :user_name            => ENV['SES_SMTP_USER_NAME'],
  :password             => ENV['SES_SMTP_PASSWORD'],
  :authentication       => :plain,
  :ssl                  => true   #For TLS SSL connection
}
