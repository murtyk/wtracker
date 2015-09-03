include ActionView::Helpers::NumberHelper
include UtilitiesHelper

# for sending auto job leads to students
class AutoMailer < ActionMailer::Base
  PLACEHOLDERS = %w($PROFILELINK$ $DIRECTOR$ $TRAINEEFIRSTNAME$
                    $JOBLEADS$ $VIEWJOBSLINK$ $OPTOUTLINK$ $APPLICANT_NAME$
                    $TRAINEE_SIGNIN_LINK$ $PASSWORD$)
  delegate :use_job_leads_email, :use_standard_email, to: EmailSettings

  def solicit_job_search_profile(trainee)
    grant          = trainee.grant

    from           = trainee.account.director
    reply_to_email = grant.reply_to_email || from.email
    to_email       = trainee.email

    profile_text = TraineeEmailTextBuilder.new.profile_request_body(trainee)
    mail(to:      to_email,
         subject: grant.profile_request_subject.content,
         from:    'JobLeads<jobleads@operoinc.com>',
         reply_to: reply_to_email) do |format|
           format.html { render inline: profile_text }
         end

    Rails.logger.info "sent job search profile request to #{trainee.name}"
  end

  def send_job_leads(auto_shared_jobs)
    return if auto_shared_jobs.blank?
    account  = auto_shared_jobs.first.account
    trainee  = Trainee.unscoped.where(id: auto_shared_jobs.first.trainee_id).first
    from     = account.director
    to_email = trainee.email

    reply_to_email = trainee.grant.reply_to_email || from.email

    job_leads_text = TraineeEmailTextBuilder.new
                     .job_leads_body(trainee, auto_shared_jobs)

    grant = trainee.grant
    mail(to:       to_email,
         subject:  grant.job_leads_subject.content,
         from:    'JobLeads<jobleads@operoinc.com>',
         reply_to: reply_to_email) do |format|
           format.html { render inline: job_leads_text }
         end

    Rails.logger.info "sent job leads email to #{to_email} : #{auto_shared_jobs.count}"
  end

  def notify_grant_status(grant, status)
    return if status.error_message
    to_email   = grant.account.director.email +
                 ';' +
                 grant.account.admins.map(&:email).join(';')
    from_email = 'JobLeads<jobleads@operoinc.com>'
    subject    =  'Job Leads - Status Summary'

    body = "<p>Job Leads Status - #{Date.today}</p>"
    body += '<hr>'
    body += auto_leads_status_body(status)

    mail(to:       to_email,
         from:     from_email,
         subject:  subject) do |format|
           format.html { render inline: body }
         end
    Rails.logger.info "sent daily job leads status summary email to #{to_email}"
  end

  def notify_status(statuses)
    to_email   = 'support@operoinc.com'
    from_email = 'JobLeads<jobleads@operoinc.com>'
    subject    =  'Auto Leads Status'

    body = "<p>Job Leads Status - #{Date.today}</p>"
    statuses.each do |status|
      body += "<b>Account: #{status.account_name}<br>Grant: #{status.grant_name}</b>"
      body += auto_leads_status_body(status)
    end

    mail(to:       to_email,
         from:     from_email,
         subject:  subject) do |format|
           format.html { render inline: body }
         end
    Rails.logger.info "sent daily job leads notification email to #{to_email}"
  end

  def notify_applicant_status(applicant)
    from      = applicant.account.admins.first
    to_email  = applicant.email
    reply_to_email = applicant.grant.reply_to_email || from.email

    subject   = applicant_notify_subject(applicant)
    body_text = applicant_notify_body(applicant)

    use_job_leads_email

    mail(to:      to_email,
         subject: subject,
         from:    'JobLeads<jobleads@operoinc.com>',
         reply_to: reply_to_email) do |format|
           format.html { render inline: body_text }
         end
    use_standard_email

    Rails.logger.info "Application confirmation email sent to #{applicant.name}"
  end

  def notify_applicant_password(applicant, password)
    from      = applicant.account.admins.first
    to_email  = applicant.email
    reply_to_email = applicant.grant.reply_to_email || from.email

    subject   = applicant_password_subject(applicant)
    body_text = applicant_password_body(applicant, password)

    use_job_leads_email

    mail(to:      to_email,
         subject: subject,
         from:    'JobLeads<jobleads@operoinc.com>',
         reply_to: reply_to_email) do |format|
           format.html { render inline: body_text }
         end
    use_standard_email

    Rails.logger.info "Application confirmation email sent to #{applicant.name}"
  end

  def applicant_reapply(applicant)
    from      = applicant.account.admins.first
    to_email  = applicant.email
    reply_to_email = applicant.grant.reply_to_email || from.email

    subject   = reapply_subject(applicant)
    body_text = reapply_body(applicant)

    use_job_leads_email

    mail(to:      to_email,
         subject: subject,
         from:    'JobLeads<jobleads@operoinc.com>',
         reply_to: reply_to_email) do |format|
           format.html { render inline: body_text }
         end
    use_standard_email

    Rails.logger.info "Applicant reapply email sent to #{applicant.name}"
  end

  def notify_hot_jobs(a_emails, subject, body)
    use_job_leads_email
    emails = a_emails.join(';')
    mail(from: 'JobLeads<jobleads@operoinc.com>',
         to: 'JobLeads<jobleads@operoinc.com>',
         bcc: emails,
         subject: subject) do |format|
           format.html { render inline: body }
         end
    use_standard_email
  end

  def notify_tapo_admin(msg, subject = 'TAPO ERROR')
    to_email = ENV['TAPO_ADMIN_EMAIL'] || 'support@operoinc.com'
    mail(to:      to_email,
         subject: subject,
         from:    'JobLeads<jobleads@operoinc.com>') do |format|
           format.html { render inline: msg }
         end
  end

  def host
    Host.host
  end

  private

  def auto_leads_status_body(status)
    body = ''
    unless status.error_messages.empty?
      body += "<p style='color: red'>Errors:</p>" + "<ol style='color: red'>"
      status.error_messages.each do |msg|
        body += "<li>#{msg}</li>"
      end
      body += '</ol><hr>'
    end
    unless status.job_search_profiles.empty?
      body += '<p>Profile Requests Sent To:</p>' + '<ol>'
      status.job_search_profiles.each do |profile|
        body += "<li>#{profile.name}</li>"
      end
      body += '</ol><hr>'
    end
    unless status.trainee_job_leads.empty?
      body += '<p>Job Leads Sent To:</p>' + '<ol>'
      status.trainee_job_leads.each do |trainee_count|
        body += "<li>#{trainee_count[0].name} - #{trainee_count[1]}</li>"
      end
      body += '</ol><hr>'
    end
    body
  end

  def parse_applicant_msg(s, applicant)
    msg = s.gsub('$FIRSTNAME$', applicant.first_name)
          .gsub('$LASTNAME$',  applicant.last_name)

    msg = msg.gsub('$LOGIN_ID$',  applicant.login_id) if applicant.accepted?

    if applicant.reapply_key
      url = edit_polymorphic_url(applicant,
                                 host: host,
                                 subdomain: applicant.account.subdomain,
                                 salt: applicant.grant.salt,
                                 key: applicant.reapply_key)

      link =  "<a href= '#{url}'>Click here</a>"
      msg = msg.gsub('$REAPPLY_LINK$',  link)
    end

    msg.gsub(/\r\n/, '<br>')
  end

  def applicant_notify_subject(applicant)
    parse_applicant_msg(applicant.email_subject, applicant)
  end

  def applicant_notify_body(applicant)
    parse_applicant_msg(applicant.email_body, applicant)
  end

  def reapply_subject(applicant)
    applicant.grant.reapply_subject
  end

  def reapply_body(applicant)
    parse_applicant_msg(applicant.grant.reapply_body, applicant)
  end

  def applicant_password_subject(applicant)
    applicant.grant.email_password_subject
  end

  def applicant_password_body(applicant, password)
    msg = parse_applicant_msg(applicant.grant.email_password_body, applicant)
    msg.gsub('$PASSWORD$', password)
  end
end
