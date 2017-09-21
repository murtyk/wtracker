class TraineeMailer < ActionMailer::Base
  def notify_credentials(trainee, password)
    to_email,
    reply_to_email,
    subject,
    body_text = ApplicantEmailTextBuilder.new(applicant)
                .email_attrs_for_password(password)

    inline_email(from_tapo, trainee.to_email, subject, body_text)

    Rails.logger.info "Applicant password email sent to #{applicant.name}"
  end

  def inline_email(f_email, t_email, subject, body)
    wait_a_bit

    atrs = { from: f_email, to: t_email, reply_to: r_email, subject: subject }
    mail(atrs) { |format| format.html { render inline: body } }
  end

  def from_tapo
    "TAPO<#{ENV['JOB_LEADS_EMAIL']}>"
  end
end
