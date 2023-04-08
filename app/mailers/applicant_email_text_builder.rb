# frozen_string_literal: true

# for building messages during applicant registration process
class ApplicantEmailTextBuilder
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  attr_reader :applicant

  def initialize(ap)
    @applicant = ap
  end

  def email_attrs_for_notify
    to_email, reply_to_email = email_addresses

    [to_email, reply_to_email, notify_subject, notify_body]
  end

  def email_attrs_for_password(password)
    to_email,
    reply_to_email = email_addresses

    subject   = password_subject
    body_text = password_body(password)

    [to_email, reply_to_email, subject, body_text]
  end

  def email_attrs_for_reapply
    to_email,
    reply_to_email = email_addresses

    subject   = reapply_subject
    body_text = reapply_body

    [to_email, reply_to_email, subject, body_text]
  end

  private

  def email_addresses
    from      = applicant.account.admins.first
    to_email  = applicant.email
    reply_to_email = applicant.grant.reply_to_email || from.email
    [to_email, reply_to_email]
  end

  def notify_subject
    parse_msg(applicant.email_subject)
  end

  def notify_body
    parse_msg(applicant.email_body)
  end

  def password_subject
    applicant.grant.email_password_subject
  end

  def password_body(password)
    msg = parse_msg(applicant.grant.email_password_body)
    msg.gsub('$PASSWORD$', password)
  end

  def reapply_subject
    applicant.grant.reapply_subject
  end

  def reapply_body
    parse_msg(applicant.grant.reapply_body)
  end

  def parse_msg(s)
    msg = parse_applicant_identity(s)

    msg = parse_reapply_link(msg) if applicant.reapply_key

    msg.gsub(/\r\n/, '<br>')
  end

  def parse_applicant_identity(s)
    msg = s.gsub('$FIRSTNAME$', applicant.first_name)
           .gsub('$LASTNAME$', applicant.last_name)

    return msg unless applicant.accepted?

    msg.gsub('$LOGIN_ID$',  applicant.login_id)
  end

  def parse_reapply_link(s)
    url = edit_polymorphic_url(applicant,
                               host: host,
                               subdomain: applicant.account.subdomain,
                               salt: applicant.grant.salt,
                               key: applicant.reapply_key)

    link = "<a href= '#{url}'>Click here</a>"
    s.gsub('$REAPPLY_LINK$', link)
  end

  def host
    Host.host
  end
end
