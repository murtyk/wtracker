# for sending app health and critical issue notifications to app admin
class AdminMailer < ActionMailer::Base
  def notify_applicant_missing(trainee)
    applicant_id = Applicant.where(email: trainee.email).first.try(:id).to_s

    subject = 'Applicant Missing'

    body_text =
      "Trainee id: #{trainee.id} email: #{trainee.email} applicant_id: #{applicant_id}"

    inline_email(from_tapo, ENV['GMAIL_USER_NAME'], subject, body_text)
  end

  def notify_hub_report_errors(errors)
    subject = 'Errors in hub report'

    body_text = errors.join("\n")

    inline_email(from_tapo, ENV['GMAIL_USER_NAME'], subject, body_text)
  end

  def inline_email(f_email, t_email, subject, body)
    atrs = { from: f_email, to: t_email, subject: subject }
    mail(atrs) { |format| format.html { render inline: body } }
  end

  def from_tapo
    "TAPO<#{ENV['JOB_LEADS_EMAIL']}>"
  end
end
