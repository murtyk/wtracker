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
    @page = params[:page]
    @template = path_dir + 'index'
    init_by_status(params) if params[:status]
    init_skill_metrics if params[:skill_metrics]
  end

  # on dashboard
  def counts_by_status
    summary_metrics.counts_by_status
  end

  # on dashboard
  def metrics_by_trainee
    altm.metrics(trainees_list)
  end

  # link from dashboard
  def init_skill_metrics
    @skill_metrics = SkillMetrics.new.generate
    @template = path_dir + 'skill_metrics'
  end

  # link from dashboard
  def init_by_status(params)
    by_status(params[:status])

    return unless params[:map]
    jsp_map = JobSearchProfilesMap.new(trainees)
    @map = jsp_map.map
    @template += '_map'
  end

  # link from dashboard
  def by_status(status)
    status_method = METHOD_MAP[status.to_sym]
    @template = path_dir + status_method
    ids = send(status_method)
    @trainees = Trainee.includes(:job_search_profile)
                .where(id: ids)
                .order(:first, :last)
                .paginate(page: @page, per_page: 40)
  end

  def trainee_job_counts
    AutoSharedJob.where(trainee_id: page_trainee_ids).group(:trainee_id).count
  end

  def pagination_date
    trainees_page
  end

  private

  def summary_metrics
    @summary_metrics ||= AutoLeadsSummaryMetrics.new(trainee_ids)
  end

  def altm
    @altm ||= AutoLeadsTraineeMetrics.new(page_trainee_ids)
  end

  def trainees_page
    @trainees_page ||= Trainee
                       .order(:first, :last)
                       .paginate(page: @page, per_page: 25)
  end

  def trainees_list
    @trainees_list ||= trainees_page.pluck(:id, :first, :last)
  end

  def trainees_with_valid_job_search_profiles
    JobSearchProfile.where(trainee_id: trainee_ids)
      .where('skills is not null').pluck(:trainee_id)
  end

  def trainees_pending_job_search_profiles
    trainee_ids - trainees_with_valid_job_search_profiles
  end

  def trainees_viewed_auto_leads
    TraineeAutoLeadStatus.where(viewed: true).pluck(:trainee_id)
  end

  def trainees_applied_auto_leads
    TraineeAutoLeadStatus.where(applied: true).pluck(:trainee_id)
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
    @trainee_ids ||= Trainee.pluck(:id)
  end

  def page_trainee_ids
    @page_trainee_ids ||= trainees_page.pluck(:id)
  end

  def path_dir
    'auto_leads_metrics/'
  end
end
