# include Icalendar # You should do this in your class to limit namespace overlap
require 'icalendar'
include ActionView::Helpers::NumberHelper
include UtilitiesHelper

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
    logger.info "in UserMailer forward_job_lead #{shared_job_status.id} /
                          current account id = #{Account.current_id}"

    from = shared_job_status.from_user
    logger.info "in UserMailer forward_job_lead from = #{from.name}"

    from_email = "#{from.name}<#{from.email}>"
    to_email = shared_job_status.to_email
    @url_link = polymorphic_url(shared_job_status, key: shared_job_status.key)
    @job_share = shared_job_status.shared_job.job_share
    @job_title = shared_job_status.title

    if from.copy_job_shares?
      mail to: to_email, subject: 'Job Suggestion from:' + from.name,
           from: from_email, reply_to: from.email, cc: from.email
    else
      mail to: to_email, subject: 'Job Suggestion from:' + from.name,
           from: from_email, reply_to: from.email
    end

    logger.info " finished UserMailer forward_job_lead #{shared_job_status.id}"
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
    @klass_event = klass_event

    # need to confirm the recepients
    to_emails = User.where(role: 2).pluck(:email).join(';')
    to_emails += ';' + klass_event.klass.navigators
                                  .pluck(:email)
                                  .join(';') if klass_event.klass.navigators.any?
    to_emails += ';' + klass_event.klass
                                  .instructors
                                  .pluck(:email)
                                  .join(';') if klass_event.klass.instructors.any?

    to_emails = User.where(role: 1).first.email if to_emails.blank?

    if user
      from = user
      from_email = "#{from.name}<#{from.email}>"
    else
      from = 'ManageE2E Application'
      from_email = 'Support<managee2e@operoinc.com>'
    end

    @cal = Icalendar::Calendar.new
    @cal.ip_method = f_cancel ? 'CANCEL' : 'REQUEST'

    @event = Icalendar::Event.new
    if klass_event.start_time_hr && klass_event.start_time_hr > 0
      @event.dtstart = format_date_time(klass_event.event_date,
                                        klass_event.start_time_hr,
                                        klass_event.start_time_min,
                                        klass_event.start_ampm)
      @event.dtend = format_date_time(klass_event.event_date,
                                      klass_event.end_time_hr,
                                      klass_event.end_time_min,
                                      klass_event.end_ampm) if klass_event.end_time_hr &&
                                                               klass_event.end_time_hr > 0
    else
      @event.dtstart       = klass_event.event_date
      @event.dtend         = klass_event.event_date
    end
    @event.summary       = klass_event.name

    # @event.organizer     = user.email if user
    # @event.custom_property("ORGANIZER;CN=#{user.name}:mailto", user.email) if user
    @event.organizer     = 'donotreply@operoinc.com'

    @event.description   = klass_event.klass_name +
                           ' - ' + klass_event.name + ' - ' + klass_event.notes
    if klass_event.name.downcase.include?('visit')
      if employer = klass_event.employers.first
        @event.description   += ' - ' + employer.name
        @event.description   += ' - ' + format_phone_no(employer.phone_no)
        @event.description   += ' - ' + employer.formatted_address
      end
    end
    @event.klass    = 'PRIVATE'
    @event.uid      = klass_event.uid
    @event.sequence = klass_event.sequence
    @cal.add_event(@event)

    # debugger
    subject = klass_event.name
    subject += (@event.sequence > 0) ? ' - UPDATE' : ' - NEW'
    mail to: to_emails, subject: subject, from: from_email, content_type: 'text/calendar'
  end

  def send_employer_emails(email, docs)
    @email = email
    docs.each { |k, v| attachments[k] = v } if docs
    to_emails = email.contacts.pluck(:email).join(';')
    mail to: email.sender, bcc: to_emails,
         subject: email.subject, from: email.sender,
         reply_to: email.sender_email_address
  end

  def send_trainee_email(trainee_email, email_addresses, use_job_leads_setting = false)
    @email = trainee_email
    to_emails = email_addresses.join(';')
    if use_job_leads_setting
      message = mail(to: @email.sender,
                    bcc: to_emails,
                    subject: @email.subject,
                    from: EmailSettings::JOB_LEADS_SETTINGS[:user_name],
                    reply_to: @email.sender_email_address,
                    delivery_method_options: EmailSettings::JOB_LEADS_SETTINGS)
    else
      message = mail(to: @email.sender,
                      bcc: to_emails,
                      subject: @email.subject,
                      from: ActionMailer::Base.smtp_settings[:user_name],
                      reply_to: @email.sender_email_address)
    end
    message
  end

  private

  def format_date_time(dt, hr, m, ampm)
    hr += 12 if ampm == 'pm'
    hour = ('00' + hr.to_s)[-2..-1]
    minutes = ('00' + m.to_s)[-2..-1]
    dt.strftime('%Y%m%d') + 'T' + hour + minutes + '00'
  end
end
