# frozen_string_literal: true

# for sending grant level daily job leads notification
class JobLeadsStatusMailer < ActionMailer::Base
  def notify(grant, leads)
    to_email = to_emails(grant)
    subject = "Job Leads - Status Summary - #{grant.name}"
    body = build_body(leads)

    inline_email(from_job_leads, to_email, subject, body)

    log_entry "sent leads status summary email grant: #{grant.name} to #{to_email}"
  end

  def inline_email(f_email, t_email, subject, body)
    atrs = { from: f_email, to: t_email, subject: subject }
    mail(atrs) { |format| format.html { render inline: body } }
  end

  def to_emails(grant)
    "#{grant.account.director.email};#{grant.account.admins.map(&:email).join(';')}"
  end

  def build_body(leads)
    body = '<p>Job Leads Sent To:</p><ol>'
    leads.each do |lead|
      body += "<li>#{lead}</li>"
    end
    "#{body}</ol><hr>"
  end

  def from_job_leads
    email = ENV['GMAIL_USER_NAME']
    "JobLeads<#{email}>"
  end

  def log_entry(msg)
    Rails.logger.info msg
  end
end
