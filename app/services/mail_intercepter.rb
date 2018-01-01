# for demo accounts, send all emails to ENV['GMAIL_USER_NAME']
class MailIntercepter
  def self.delivering_email(mail)
    if Account.find(Account.current_id).demo
      mail.to = ENV['GMAIL_USER_NAME']
      mail.cc = nil
      mail.bcc = nil
    end
  end
end
