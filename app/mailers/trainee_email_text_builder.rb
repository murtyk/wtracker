# build subject and content for autl leads emails to trainees
# works for all types of grants
class TraineeEmailTextBuilder
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  attr_reader :trainee, :jobs
  def job_leads_body(trainee, jobs = [])
    @trainee = trainee
    @jobs = jobs

    body = job_leads_raw_body
    body = body.gsub('$JOBLEADS$', job_leads_html) if jobs.any?

    body.gsub('$TRAINEEFIRSTNAME$', trainee.first)
      .gsub('$VIEWJOBSLINK$', view_jobs_link)
      .gsub('$TRAINEE_SIGNIN_LINK$', sign_in_link(trainee))
      .gsub('$OPTOUTLINK$', opt_out_link)
  end

  def profile_request_body(trainee)
    @trainee = trainee

    profile_request_raw_body
      .gsub('$PROFILELINK$', profile_link)
      .gsub('$DIRECTOR$', director_email_link)
  end

  private

  def profile_link
    url = edit_polymorphic_url(job_search_profile,
                               host: host,
                               subdomain: subdomain,
                               key: job_search_profile.key)

    "<a href= '#{url}'>my profile</a>"
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
    grant.job_leads_content.content.gsub(/\r\n/, '<br>')
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

  def opt_out_link
    url = edit_polymorphic_url(job_search_profile,
                               host: host, subdomain: subdomain,
                               key: job_search_profile.key,
                               opt_out: true)

    "<a href='#{url}'>Click here to opt out from job leads.</a>"
  end

  def job_leads_html
    '<ol>' +
      jobs.map do |job|
        "<li>#{job.title} - #{job.company}</li>"
      end.join +
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
