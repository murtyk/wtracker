# include Icalendar # You should do this in your class to limit namespace overlap
require 'icalendar'
include ActionView::Helpers::NumberHelper
include UtilitiesHelper

# user action based emails: job leads, klass events etc.
class UserMailer < ActionMailer::Base
  def enquire_job_lead_status(shared_job_status)
    from = shared_job_status.from_user
    from_email = "#{from.name}<#{from.email}>"
    to_email = shared_job_status.to_email

    @shared_job_status = shared_job_status
    @url_link = polymorphic_url(shared_job_status, key: shared_job_status.key)

    mail to: to_email, subject: 'Have you applied for the job lead we sent you?',
         from: from_email, reply_to: from.email, cc: from.email
  end

  def forward_job_lead(shared_job_status)
    # debugger if Account.current_id.nil?
    from = shared_job_status.from_user
    from_name = from.name
    from_email = "#{from_name}<#{from.email}>"

    @url_link = polymorphic_url(shared_job_status, key: shared_job_status.key)
    @job_share = shared_job_status.shared_job.job_share
    @job_title = shared_job_status.title

    mail_params = { to: shared_job_status.to_email,
                    subject: 'Job Suggestion from:' + from_name,
                    from: from_email,
                    reply_to: from_email }

    mail_params[:cc] = from_email if from.copy_job_shares?

    mail mail_params
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.share_jobs.subject
  #
  def share_jobs(job_share, to_emails)
    @job_share = job_share

    from = @job_share.from_user

    from_email = "#{from.name}<#{from.email}>"

    if from.copy_job_shares?
      mail to: to_emails, subject: 'Job Suggestion from:' + from.name,
           from: from_email, reply_to: from.email, cc: from.email
    else
      mail to: to_emails, subject: 'Job Suggestion from:' + from.name,
           from: from_email, reply_to: from.email
    end
  end

  def send_event_invite(klass_event, user = nil, f_cancel = false)
    return

    eb = EventMailBuilder.new(klass_event, user, f_cancel)
    eb.build
    @cal = eb.ical

    mail to: eb.to_emails,
         subject: eb.subject,
         from: eb.from_email,
         content_type: 'text/calendar'
  end

  def send_employer_emails(email, docs)
    @email = email
    docs.each { |k, v| attachments[k] = v } if docs
    to_emails = email.contacts.pluck(:email).join(';')
    mail to: email.sender, bcc: to_emails,
         subject: email.subject, from: email.sender,
         reply_to: email.sender_email_address
  end

  def send_trainee_email(trainee_email, email_addresses)
    @email = trainee_email
    to_emails = email_addresses.join(';')
    mail(to: @email.sender,
      bcc: to_emails,
      subject: @email.subject,
      from: ENV['GMAIL_USER_NAME'],
      reply_to: @email.sender_email_address)
  end

  def send_data(user, subject, body, docs = nil)
    docs.each { |k, v| attachments[k] = v } if docs
    mail(to: user.email,
         subject: subject,
         from: "Support<#{ENV['SUPPORT_FROM_EMAIL']}>") do |format|
           format.html { render inline: body }
         end
  end
end
