ActionMailer::Base.smtp_settings = {
    enable_starttls_auto: true,
    address: "smtp.gmail.com",
    port: 587,
    domain: "opero.com",
    authentication: :login,
    user_name: ENV['GMAIL_USER_NAME'],
    password: ENV['GMAIL_PASSWORD']
}