# frozen_string_literal: true

# queues one job for each trainee for auto leads
class QueueAutoLeadsJobs
  include ActiveSupport

  class << self
    def perform
      new.perform
    end
  end

  def perform
    return if skip_lead_generation?

    log_info 'AutoJobLeads: performing'

    log_info 'AutoJobLeads: creating missing job search profiles'
    JobSearchProfileJob.new.perform

    perform_grants
  end

  def perform_grants
    grants_for_auto_leads.each do |grant|
      Account.current_id = grant.account_id
      Grant.current_id   = grant.id

      next unless grant.trainees.any?
      next unless grant.email_messages_defined?

      perform_grant_trainees(grant)
    end
  end

  def perform_grant_trainees(grant)
    grant_name = "#{grant.account_name} - #{grant.name}"

    log_info "AutoJobLeads: started queuing leads jobs for #{grant_name}"

    grant.not_disabled_trainees.find_each do |trainee|
      perform_action_for_trainee(trainee) # if trainee.has_feature?("job_leads")
    end

    GrantAutoLeadsStatus.delay(queue: 'daily').perform(grant.id)

    log_info "AutoJobLeads: completed queuing leads jobs for #{grant_name}"
  end

  def perform_action_for_trainee(trainee)
    action = action_for_trainee(trainee)
    case action
    when :SKIP
    when :OPTED_OUT
    when :SEND_LEADS
      queue_leads_job(trainee)
    when :INCOMPLETE
    when :SOLICIT_PROFILE
      solicit_profile(trainee)
    end
  end

  def queue_leads_job(trainee)
    TraineeAutoLeads
      .delay(queue: 'daily')
      .perform(trainee.account_id, trainee.grant_id, trainee.id)
  end

  def action_for_trainee(trainee)
    return :SKIP unless trainee.valid_email?

    return :SKIP if skip_action?(trainee)

    return :OPTED_OUT if trainee.opted_out_from_auto_leads?
    return :SEND_LEADS if trainee.valid_profile?
    # trainee did not update with skills etc.
    return :INCOMPLETE if trainee.job_search_profile

    return :SOLICIT_PROFILE if can_solicit_profile?(trainee.grant)

    nil
  end

  def skip_lead_generation?
    if ENV['SKIP_AUTO_LEADS'] == 'YES'
      log_info "AutoJobLeads: skipping auto leads env setting #{Date.today}"
      return true
    end

    log_info "AutoJobLeads: started today: #{Date.today}"

    last_lead_sent_today?
  end

  def last_lead_sent_today?
    asj = AutoSharedJob.last

    return false unless asj

    prev_date = Date.parse(asj.created_at.to_s)

    return false if Date.today > prev_date

    log_info "AutoJobLeads: skipping  prev_date: #{prev_date}"
    true
  end

  def skip_action?(trainee)
    trainee.skip_auto_leads || trainee.incumbent? || !trainee.not_placed?
  end

  def solicit_profile(t)
    tp = t.job_search_profile ||
         t.create_job_search_profile(account_id: t.account_id,
                                     key: random_key)

    AutoMailer.solicit_job_search_profile(t).deliver_now
    tp
  end

  def can_solicit_profile?(grant)
    !(grant.trainee_applications? || grant.skip_profile_solication)
  end

  def grants_for_auto_leads
    Grant
      .unscoped
      .where('status < 3')
      .load
      .select(&:auto_job_leads?)
  end

  def random_key
    SecureRandom.urlsafe_base64(6)
  end

  def log_info(msg)
    Rails.logger.info msg
  end
end
