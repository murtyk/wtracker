# trainee metrics for a grant with auto job leads
class AutoLeadsMetrics
  attr_reader :template

  METHOD_MAP =  { PENDING:     'trainees_pending_job_search_profiles',
                  NOT_PENDING: 'trainees_with_valid_job_search_profiles',
                  VIEWED:      'trainees_viewed_auto_leads',
                  NOT_VIEWED:  'trainees_not_viewed_auto_leads',
                  APPLIED:     'trainees_applied_auto_leads',
                  NOT_APPLIED: 'trainees_not_applied_auto_leads',
                  OPTED_OUT:   'trainees_opted_out' }

  def metrics_by_trainee
    trainees_list.map do |id, name|
      trainee_metric(id, name)
    end
  end

  def trainee_metric(id, name)
    {
      id: id,
      name: name,
      valid_profile:        trainees_valid.include?(id),
      leads_count:          job_leads_counts[id],
      viewed_count:         jobs_viewed_counts[id],
      applied_count:        jobs_applied_counts[id],
      not_interested_count: not_interested_counts[id]
    }
  end

  def by_status(status)
    @template = METHOD_MAP[status.to_sym]
    ids = send(template)

    return [] if ids.empty?
    Trainee.where(id: ids).order(:first, :last)
  end

  def counts_by_status
    METHOD_MAP.map do |status, method|
      [status, send(method).count]
    end.to_h
  end

  def job_leads_sent_count
    AutoSharedJob.unscoped.where(trainee_id: trainee_ids).count
  end

  def average_leads
    valid_jsp_count = trainees_with_valid_job_search_profiles.count
    return unless valid_jsp_count > 0
    job_leads_sent_count / valid_jsp_count
  end

  private

  def trainees_list
    @trainees_list ||= Trainee.order(:first, :last)
                       .pluck(:id, :first, :last)
                       .map { |id, f, l| [id, f + ' ' + l] }
  end

  def trainees_valid
    @trainees_valid ||= trainees_with_valid_job_search_profiles
  end

  def asjs
    @asjs ||= AutoSharedJob.where(trainee_id: trainee_ids)
  end

  def job_leads_counts
    @job_leads_counts ||= asjs.group(:trainee_id).count
  end

  def jobs_viewed_counts
    @jobs_viewed_counts ||= asjs.where('status > 0 and status < 4')
                            .group(:trainee_id).count
  end

  def jobs_applied_counts
    @jobs_applied_counts ||= asjs.where(status: 2).group(:trainee_id).count
  end

  def not_interested_counts
    @not_interested_counts ||= asjs.where(status: [3, 4]).group(:trainee_id).count
  end

  def trainees_with_valid_job_search_profiles
    JobSearchProfile.where(trainee_id: trainee_ids)
      .where('skills is not null').pluck(:trainee_id)
  end

  def trainees_pending_job_search_profiles
    trainee_ids - trainees_with_valid_job_search_profiles
  end

  def trainees_viewed_auto_leads
    AutoSharedJob.select(:trainee_id)
      .where(trainee_id: trainee_ids)
      .where('status > 0 and status < 4').pluck(:trainee_id).uniq
  end

  def trainees_applied_auto_leads
    AutoSharedJob.select(:trainee_id)
      .where(trainee_id: trainee_ids)
      .where('status = 2').pluck(:trainee_id).uniq
  end

  def trainees_not_applied_auto_leads
    trainee_ids - trainees_applied_auto_leads
  end

  def trainees_not_viewed_auto_leads
    trainee_ids - trainees_viewed_auto_leads
  end

  def trainees_opted_out
    JobSearchProfile.where(opted_out: true, trainee_id: trainee_ids).pluck(:trainee_id)
  end

  def trainee_ids
    @trainee_ids = Trainee.pluck(:id)
  end
end
