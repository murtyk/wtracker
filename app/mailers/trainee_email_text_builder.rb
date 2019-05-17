# build subject and content for autl leads emails to trainees
# works for all types of grants
class TraineeEmailTextBuilder
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  attr_reader :trainee, :jobs

  def initialize(trainee)
    @jobs = []
    @trainee = trainee
  end

  def job_leads_email_attrs(jobs)
    @jobs = jobs
    grant = trainee.grant

    to_email,
    reply_to_email = email_addresses

    subject = grant.job_leads_subject.content
    body_text = job_leads_body

    [to_email, reply_to_email, subject, body_text]
  end

  def profile_request_attributes
    to_email, reply_to_email = email_addresses

    grant   = trainee.grant
    subject = grant.profile_request_subject.content

    body_text = profile_request_body
    [to_email, reply_to_email, subject, body_text]
  end

  def email_addresses
    from           = trainee.account.director
    grant          = trainee.grant
    reply_to_email = grant.reply_to_email || from.email

    [trainee.email, reply_to_email]
  end

  def job_leads_body
    body = job_leads_raw_body
    body = body.gsub('$JOBLEADS$', job_leads_html) if jobs.any?

    body.gsub('$TRAINEEFIRSTNAME$', trainee.first)
        .gsub('$VIEWJOBSLINK$', view_jobs_link)
        .gsub('$TRAINEE_SIGNIN_LINK$', sign_in_link(trainee))
        .gsub('$OPTOUTLINK$', opt_out_link)
  end

  def profile_request_body
    profile_request_raw_body
      .gsub('$PROFILELINK$', profile_link)
      .gsub('$DIRECTOR$', director_email_link)
  end

  private

  def profile_link
    "<a href= '#{profile_edit_url}'>my profile</a>"
  end

  def opt_out_link
    url = profile_edit_url(true)

    "<a href='#{url}'>Click here to opt out from job leads.</a>"
  end

  def profile_edit_url(optout = false)
    options = { host: host, subdomain: subdomain, key: job_search_profile.key }
    options[:opt_out] = true if optout
    edit_polymorphic_url(job_search_profile, options)
  end

  def profile_request_raw_body
    grant.profile_request_content.content.gsub(/\r\n/, '<br>')
  end

  def director_email_link
    "<a href='mailto:#{director_email}' target='_top'>#{director_name}</a>"
  end

  def director_name
    director.name
  end

  def director_email
    director.email
  end

  def director
    trainee.account.director
  end

  def job_leads_raw_body
    raw_body = grant.job_leads_content.content.gsub(/\r\n/, '<br>')
    return raw_body unless grant.closing

    grant.closing_job_leads_message + '<br>' + raw_body
  end

  def sign_in_link(trainee)
    Host.sign_in_link(trainee, 'Click here to sign in and view jobs.')
  end

  def view_jobs_link
    url = polymorphic_url(job_search_profile,
                          host: host, subdomain: subdomain,
                          key: job_search_profile.key)

    "<a href= '#{url}'>Click here to view and apply for jobs.</a>"
  end

  def job_leads_html
    return '' unless jobs.any?

    '<ol>' +
      jobs.map { |job| "<li>#{job.title} - #{job.company}</li>" }.join +
      '</ol>'
  end

  def job_search_profile
    trainee.job_search_profile
  end

  def grant
    trainee.grant
  end

  def subdomain
    trainee.account.subdomain
  end

  def host
    Host.host
  end
end
