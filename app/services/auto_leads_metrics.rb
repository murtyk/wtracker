# trainee dashboard metrics for a grant with auto job leads
class AutoLeadsMetrics < DashboardMetrics
  attr_reader :trainees, :map, :skill_metrics

  METHOD_MAP =  { PENDING:     'trainees_pending_job_search_profiles',
                  NOT_PENDING: 'trainees_with_valid_job_search_profiles',
                  VIEWED:      'trainees_viewed_auto_leads',
                  NOT_VIEWED:  'trainees_not_viewed_auto_leads',
                  APPLIED:     'trainees_applied_auto_leads',
                  NOT_APPLIED: 'trainees_not_applied_auto_leads',
                  OPTED_OUT:   'trainees_opted_out' }

  def initialize(params)
    @template = path_dir + 'index'
    init_by_status(params) if params[:status]
    init_skill_metrics if params[:skill_metrics]
  end

  def init_by_status(params)
    by_status(params[:status])

    return unless params[:map]
    jsp_map = JobSearchProfilesMap.new(trainees)
    @map = jsp_map.map
    @template += '_map'
  end

  def init_skill_metrics
    @skill_metrics = SkillMetrics.new.generate
    @template = path_dir + 'skill_metrics'
  end

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
    status_method = METHOD_MAP[status.to_sym]
    @template = path_dir + status_method
    ids = send(status_method)
    @trainees = Trainee.includes(:job_search_profile).where(id: ids).order(:first, :last)
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

  def trainee_job_counts
    AutoSharedJob.where(trainee_id: trainee_ids).group(:trainee_id).count
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

  def path_dir
    'auto_leads_metrics/'
  end
end
