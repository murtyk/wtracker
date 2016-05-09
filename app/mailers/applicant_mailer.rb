# for sending applicant registration process messages
class ApplicantMailer < ActionMailer::Base
  PLACEHOLDERS = %w($PROFILELINK$ $DIRECTOR$ $TRAINEEFIRSTNAME$
                    $JOBLEADS$ $VIEWJOBSLINK$ $OPTOUTLINK$ $APPLICANT_NAME$
                    $TRAINEE_SIGNIN_LINK$ $PASSWORD$)
  delegate :use_job_leads_email, :use_standard_email, to: EmailSettings

  def notify_applicant_status(applicant)
    to_email,
    reply_to_email,
    subject,
    body_text = ApplicantEmailTextBuilder.new(applicant)
                .email_attrs_for_notify

    inline_email(from_job_leads, to_email, reply_to_email, subject, body_text)

    Rails.logger.info "Application confirmation email sent to #{applicant.name}"
  end

  def notify_applicant_password(applicant, password)
    to_email,
    reply_to_email,
    subject,
    body_text = ApplicantEmailTextBuilder.new(applicant)
                .email_attrs_for_password(password)

    inline_email(from_job_leads, to_email, reply_to_email, subject, body_text)

    Rails.logger.info "Applicant password email sent to #{applicant.name}"
  end

  def applicant_reapply(applicant)
    to_email,
    reply_to_email,
    subject,
    body_text = ApplicantEmailTextBuilder.new(applicant)
                .email_attrs_for_reapply

    inline_email(from_job_leads, to_email, reply_to_email, subject, body_text)

    Rails.logger.info "Applicant reapply email sent to #{applicant.name}"
  end

  def notify_hot_jobs(a_emails, subject, body)
    use_job_leads_email
    emails = a_emails.join(';')
    mail(from: from_job_leads,
         to: from_job_leads,
         bcc: emails,
         subject: subject) do |format|
           format.html { render inline: body }
         end
    use_standard_email
  end

  private

  def inline_email(f_email, t_email, r_email, subject, body)
    use_job_leads_email
    wait_a_bit

    atrs = { from: f_email, to: t_email, reply_to: r_email, subject: subject }
    mail(atrs) { |format| format.html { render inline: body } }

    use_standard_email
  end

  def wait_a_bit
    sleep 5 if Rails.env.production?
  end

  def log_entry(msg)
    Rails.logger.info msg
  end

  def from_job_leads
    "JobLeads<ENV['JOB_LEADS_EMAIL']>"
  end

  def support_email
    ENV['SUPPORT_FROM_EMAIL']
  end
end
