# when a grant is set for auto job leads, the trainees in that grant get job leads daily
# first check if trainee has updates job search profile. If not send an email
# find matching jobs for each trainee and send them in an email
# find the most recent (max) job posted date from the leads sent earlier
# only send the jobs with posted date later than above
class FillLeadsQueueJob
  include ActiveSupport
  attr_accessor :error_messages

  def perform
    return if skip_lead_generation?
    Rails.logger.info 'FillLeadsQueueJob: performing'
    @error_messages = []
    fill_leads_queue

    Rails.logger.info 'FillLeadsQueueJob: done'
  end

  def fill_leads_queue
    grants_for_auto_leads.each do |grant|
      Account.current_id = grant.account_id
      Grant.current_id   = grant.id
      if grant.email_messages_defined?
        grant_trainee_actions(grant)
      end
    end
  end

  def grant_trainee_actions(grant)
    init_grant_data(grant)
    grant.trainees.includes(:leads_queue, :job_search_profile).each do |trainee|
      perform_action_for_trainee(trainee)
    end
    Rails.logger.info "FillLeadsQueueJob: completed leads for #{grant.name}"
  end

  def perform_action_for_trainee(trainee)
    action = action_for_trainee(trainee)
    send_lead_for(trainee) if action == :SEND_LEADS
    skip_lead_for(trainee) unless action == :SEND_LEADS
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

  def send_lead_for(trainee)
    q_params = build_q_params(trainee, :pending)
    q = trainee.leads_queue

    q.update(q_params) if q
    trainee.create_leads_queue(q_params) unless q
  end

  def skip_lead_for(trainee)
    q = trainee.leads_queue
    return unless q
    q.update(status: :inactive)
  end

  def build_q_params(trainee, status)
    jsp = trainee.job_search_profile
    last_lead = trainee.auto_shared_jobs.last
    {
      trainee_ip: trainee_ip(trainee),
      status: status,
      last_lead_at: last_lead && last_lead.created_at,
      jsp_id: jsp.id,
      skills: jsp.skills,
      distance: jsp.distance,
      location: jsp.location
    }.merge @email_attributes
  end

  def trainee_ip(trainee)
    agent = trainee.agent
    return unless agent && agent.info
    agent.info['ip']
  end

  def init_grant_data(grant)
    @email_attributes = {
      email_from:     'JobLeads<jobleads@operoinc.com>',
      email_reply_to: grant.reply_to_email || grant.account.director.email,
      email_subject:  grant.job_leads_subject.content,
      email_body:     grant.job_leads_content.content
    }
  end

  def skip_lead_generation?
    if ENV['SKIP_AUTO_LEADS'] == 'YES'
      Rails.logger.info "FillLeadsQueueJob: skipping auto leads env setting #{Date.today}"
      return true
    end

    Rails.logger.info "FillLeadsQueueJob: started today: #{Date.today}"

    last_lead_sent_today?
  end

  def last_lead_sent_today?
    asj = AutoSharedJob.last

    return false unless asj

    prev_date = Date.parse(asj.created_at.to_s)

    return false if Date.today > prev_date

    Rails.logger.info "FillLeadsQueueJob: skipping  prev_date: #{prev_date}"
    true
  end

  def grants_for_auto_leads
    grants = Grant.unscoped.where('status < 3').load
    grants.map { |g| g if g.auto_job_leads? }.compact
  end
end
