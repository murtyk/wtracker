# frozen_string_literal: true

# For sending login credentials to trainee when job search profile is created
#   Specifically designed for Amazon grant
class TraineeMailer < ActionMailer::Base
  def notify_credentials(trainee, password)
    subject,
    body_text = TraineeCredentialsEmailTextBuilder.new(trainee)
                                                  .email_attrs_for_credentials(password)

    inline_email(from_tapo, trainee.email, subject, body_text)

    msg = "credentials sent to #{trainee.email} #{trainee.name} #{trainee.id}"
    Rails.logger.info("TraineeMailer: #{msg}")
  end

  def inline_email(f_email, t_email, subject, body)
    atrs = { from: f_email, to: t_email, subject: subject }
    mail(atrs) { |format| format.html { render inline: body } }
  end

  def from_tapo
    "TAPO<#{ENV['JOB_LEADS_EMAIL']}>"
  end
end
