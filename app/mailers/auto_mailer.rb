# frozen_string_literal: true

include ActionView::Helpers::NumberHelper
include UtilitiesHelper

# for sending auto job leads to students
class AutoMailer < ActionMailer::Base
  PLACEHOLDERS = %w[$PROFILELINK$ $DIRECTOR$ $TRAINEEFIRSTNAME$
                    $JOBLEADS$ $VIEWJOBSLINK$ $OPTOUTLINK$ $APPLICANT_NAME$
                    $TRAINEE_SIGNIN_LINK$ $PASSWORD$].freeze

  def solicit_job_search_profile(trainee)
    to_email,
    reply_to_email,
    subject,
    body_text = TraineeEmailTextBuilder.new(trainee).profile_request_attributes

    inline_email(from_job_leads, to_email, reply_to_email, subject, body_text)

    Rails.logger.info "sent job search profile request to #{trainee.name}"
  end

  def send_job_leads(auto_shared_jobs)
    return if auto_shared_jobs.blank?

    trainee_id = auto_shared_jobs.first.trainee_id
    trainee = Trainee.unscoped.where(id: trainee_id).first

    Account.current_id = trainee.account_id
    Grant.current_id = trainee.grant_id

    to_email,
    reply_to_email,
    subject,
    body_text = TraineeEmailTextBuilder.new(trainee)
                                       .job_leads_email_attrs(auto_shared_jobs)

    inline_email(from_job_leads, to_email, reply_to_email, subject, body_text)

    log_entry "sent job leads email to #{to_email} : #{auto_shared_jobs.count}"
  end

  def notify_grant_status(grant, status)
    return if status.error_message

    to_email = grant_status_to_emails(grant)
    subject = 'Job Leads - Status Summary'
    body = grant_status_body(status)

    inline_email(from_job_leads, to_email, nil, subject, body)

    log_entry "sent daily job leads status summary email to #{to_email}"
  end

  def notify_status(statuses)
    subject = 'Auto Leads Status'

    body = "<p>Job Leads Status - #{Date.today}</p>"
    statuses.each do |status|
      body += "<b>Account: #{status.account_name}<br>"
      body += "Grant: #{status.grant_name}</b>"
      body += auto_leads_status_body(status)
    end

    inline_email(from_job_leads, support_email, nil, subject, body)

    log_entry "sent daily job leads notification email to #{support_email}"
  end

  def notify_hot_jobs(a_emails, subject, body)
    emails = a_emails.join(';')
    mail(from: from_job_leads,
         to: from_job_leads,
         bcc: emails,
         subject: subject) do |format|
           format.html { render inline: body }
         end
  end

  def notify_tapo_admin(msg, subject = 'TAPO ERROR')
    to_email = ENV['TAPO_ADMIN_EMAIL'] || support_email

    inline_email(from_job_leads, to_email, nil, subject, msg)
  end

  private

  def grant_status_to_emails(grant)
    "#{grant.account.director.email};#{grant.account.admins.map(&:email).join(';')}"
  end

  def grant_status_body(status)
    "<p>Job Leads Status - #{Date.today}</p>" \
    '<hr>' +
      auto_leads_status_body(status)
  end

  def inline_email(f_email, t_email, r_email, subject, body)
    atrs = { from: f_email, to: t_email, reply_to: r_email, subject: subject }
    mail(atrs) { |format| format.html { render inline: body } }
    log_entry "AutoMailer: Using #{ActionMailer::Base.smtp_settings[:user_name]}"
  end

  def auto_leads_status_body(status)
    html_for_status_error_messages(status.error_messages) +
      html_for_jsps(status.job_search_profiles) +
      html_for_trainee_job_leads(status.trainee_job_leads)
  end

  def html_for_status_error_messages(error_messages)
    return '' if error_messages.blank?

    body = "<p style='color: red'>Errors:</p><ol style='color: red'>"
    error_messages.each { |msg| body += "<li>#{msg}</li>" }
    "#{body}</ol><hr>"
  end

  def html_for_jsps(jsps)
    return '' if jsps.blank?

    body = '<p>Profile Requests Sent To:</p><ol>'
    jsps.each { |profile| body += "<li>#{profile.name}</li>" }
    "#{body}</ol><hr>"
  end

  def html_for_trainee_job_leads(trainee_job_leads)
    body = '<p>Job Leads Sent To:</p><ol>'
    trainee_job_leads.each do |trainee_count|
      body += "<li>#{trainee_count[0].name} - #{trainee_count[1]}</li>"
    end
    "#{body}</ol><hr>"
  end

  def wait_a_bit
    sleep 2
  end

  def log_entry(msg)
    Rails.logger.info msg
  end

  def from_job_leads
    email = ENV['GMAIL_USER_NAME']
    "JobLeads<#{email}>"
  end

  def support_email
    ENV['GMAIL_USER_NAME']
  end
end
