# when a grant is set for auto job leads, the trainees in that grant get job leads daily
# first check if trainee has updated job search profile. If not send an email
# find matching jobs for each trainee and send them in an email
# find the most recent (max) job posted date from the leads sent earlier
# only send the jobs with posted date later than above
class LeadsQueueFactory
  include ActiveSupport
  attr_accessor :error_messages

  def generate
    @error_messages = []
    fill_leads_queue
  end

  def fill_leads_queue
    grants_for_auto_leads.each do |grant|
      Account.current_id = grant.account_id
      Grant.current_id   = grant.id

      grant_trainee_actions(grant) if grant.email_messages_defined?
    end
  end

  def grant_trainee_actions(grant)
    init_grant_data(grant)
    grant.trainees.includes(:leads_queue, :job_search_profile).each do |trainee|
      perform_action_for_trainee(trainee)
    end
    Rails.logger.info "LeadsQueueFactory: generated for #{grant.name}"
  end

  def perform_action_for_trainee(trainee)
    action = action_for_trainee(trainee)
    queue_trainee_for_leads(trainee) if action == :SEND_LEADS
    skip_trainee_for_leads(trainee) unless action == :SEND_LEADS

    solicit_profile(trainee) if action == :SOLICIT_PROFILE
  end

  def action_for_trainee(trainee)
    return :SKIP unless trainee.not_placed?
    return :OPTED_OUT if trainee.opted_out_from_auto_leads?
    return :SEND_LEADS if trainee.valid_profile?
    # trainee did not update with skills etc.
    return :INCOMPLETE if trainee.job_search_profile
    return :SOLICIT_PROFILE if trainee.valid_email? # no profile
    @error_messages << "missing or invalid email for trainee #{trainee.name}"
    nil
  end

  def queue_trainee_for_leads(trainee)
    q_params = build_q_params(trainee, :pending)
    q = trainee.leads_queue

    q.update(q_params) if q
    trainee.create_leads_queue(q_params) unless q
  end

  def solicit_profile(t)
    tp = t.job_search_profile || t.create_job_search_profile(account_id: t.account_id,
                                                             key: random_key)

    AutoMailer.solicit_job_search_profile(t).deliver_now
    tp
  end

  def skip_trainee_for_leads(trainee)
    q = trainee.leads_queue
    return unless q
    q.update(status: :inactive)
  end

  def build_q_params(trainee, status)
    jsp = trainee.job_search_profile
    last_lead = trainee.auto_shared_jobs.order(date_posted: :desc).first
    {
      trainee_ip: trainee_ip(trainee),
      status: status,
      last_date_posted: last_lead && last_lead.date_posted,
      jsp_id: jsp.id,
      skills: jsp.skills,
      distance: jsp.distance,
      location: jsp.location,
      zip: jsp.zip
    }.merge trainee_email_data(trainee)
  end

  def trainee_ip(trainee)
    agent = trainee.agent
    return unless agent && agent.info
    agent.info['ip']
  end

  def trainee_email_data(trainee)
    @email_attributes.merge(email_body: email_body(trainee), email_to: trainee.email)
  end

  def init_grant_data(grant)
    @email_attributes = {
      email_from:     'JobLeads<jobleads@operoinc.com>',
      email_reply_to: grant.reply_to_email || grant.account.director.email,
      email_subject:  grant.job_leads_subject.content
    }
  end

  def grants_for_auto_leads
    grants = Grant.unscoped.where('status < 3').load
    grants.map { |g| g if g.auto_job_leads? }.compact
  end

  def email_body(trainee)
    @builder ||= TraineeEmailTextBuilder.new(trainee)
    @builder.job_leads_body
  end

  def random_key
    SecureRandom.urlsafe_base64(6)
  end
end
