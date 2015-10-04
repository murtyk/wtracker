# summary of leads, status, opt outs etc.
class AutoLeadsSummaryMetrics
  attr_accessor :trainee_ids

  def initialize(t_ids)
    @trainee_ids = t_ids
  end

  def counts_by_status
    { TOTAL_LEADS: job_leads_sent_count,
      AVERAGE:     average_leads,
      PENDING:     pending_job_search_profiles_count,
      NOT_PENDING: valid_job_search_profiles_count,
      VIEWED:      viewed_auto_leads_count,
      NOT_VIEWED:  not_viewed_auto_leads_count,
      APPLIED:     applied_auto_leads_count,
      NOT_APPLIED: not_applied_auto_leads_count,
      OPTED_OUT:   opted_out_count }
  end

  def pending_job_search_profiles_count
    trainee_ids.size - valid_job_search_profiles_count
  end

  def valid_job_search_profiles_count
    JobSearchProfile
      .where(trainee_id: trainee_ids)
      .where('skills is not null')
      .count
  end

  def viewed_auto_leads_count
    AutoSharedJob.select(:trainee_id)
      .where(trainee_id: trainee_ids)
      .where('status > 0 and status < 4')
      .distinct
      .count
  end

  def not_viewed_auto_leads_count
    trainee_ids.size - viewed_auto_leads_count
  end

  def applied_auto_leads_count
    AutoSharedJob.select(:trainee_id)
      .where(trainee_id: trainee_ids)
      .where('status = 2')
      .distinct
      .count
  end

  def not_applied_auto_leads_count
    trainee_ids.size - applied_auto_leads_count
  end

  def opted_out_count
    JobSearchProfile.where(opted_out: true, trainee_id: trainee_ids).count
  end

  def job_leads_sent_count
    GrantJobLeadCount.sum(:count)
  end

  def average_leads
    return unless valid_job_search_profiles_count > 0
    (job_leads_sent_count * 1.0 / valid_job_search_profiles_count).round
  end
end
