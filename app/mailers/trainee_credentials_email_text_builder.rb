# For sending login credentials to trainee when job search profile is created
#   Specifically designed for Amazon grant
class TraineeCredentialsEmailTextBuilder
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  attr_reader :trainee, :grant

  def initialize(trainee)
    @trainee = trainee
    @grant = trainee.grant
  end

  def email_attrs_for_credentials(password)
    subject   = credentials_subject
    body_text = credentials_body(password)

    [subject, body_text]
  end

  private

  def credentials_subject
    grant.credentials_email_subject
  end

  def credentials_body(password)
    msg = parse_msg(grant.credentials_email_content)
    msg.gsub('$PASSWORD$', password)
  end

  def parse_msg(s)
    msg = parse_trainee_identity(s)
    msg = parse_tapo_link(msg)
    msg.gsub(/\r\n/, '<br>')
  end

  def parse_trainee_identity(s)
    msg = s.gsub('$FIRSTNAME$', trainee.first)
           .gsub('$LASTNAME$', trainee.last)

    msg.gsub('$LOGIN_ID$', trainee.login_id)
  end

  def parse_tapo_link(s)
    login_link = Host.sign_in_link(trainee, 'Training and Placement Organizer (TaPO)')
    s.gsub('$TAPO_TRAINEE_LOGIN_LINK$', login_link)
  end
end
