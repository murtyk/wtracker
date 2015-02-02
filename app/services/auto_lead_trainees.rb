# trainee metrics for a grant with auto job leads
class AutoLeadTrainees
  attr_accessor :program
  def initialize
    @grant = Grant.find(Grant.current_id)
  end

  METHOD_MAP =  { PENDING:     'trainees_pending_job_search_profiles',
                  NOT_PENDING: 'trainees_with_valid_job_search_profiles',
                  VIEWED:      'trainees_viewed_auto_leads',
                  NOT_VIEWED:  'trainees_not_viewed_auto_leads',
                  APPLIED:     'trainees_applied_auto_leads',
                  NOT_APPLIED: 'trainees_not_applied_auto_leads',
                  OPTED_OUT:   'trainees_opted_out' }

  def metrics_by_trainee
    trainees_list         = source.trainees.pluck(:id, :first, :last)
    trainees_valid        = source.trainees_with_valid_job_search_profiles
    asjs                  = AutoSharedJob.where(trainee_id: source.trainee_ids)
    job_leads_counts      = asjs.group(:trainee_id).count
    jobs_viewed_counts    = asjs.where('status > 0 and status < 4')
                                .group(:trainee_id).count
    jobs_applied_counts   = asjs.where(status: 2).group(:trainee_id).count
    not_interested_counts = asjs.where(status: [3, 4]).group(:trainee_id).count

    trainees_metrics = []
    (0..trainees_list.count - 1).each do |n|
      t = { id: trainees_list[n][0],
            name: trainees_list[n][1] + ' ' + trainees_list[n][2] }
      t[:valid_profile]        = trainees_valid.include?(t[:id])
      t[:leads_count]          = job_leads_counts[t[:id]]
      t[:viewed_count]         = jobs_viewed_counts[t[:id]]
      t[:applied_count]        = jobs_applied_counts[t[:id]]
      t[:not_interested_count] = not_interested_counts[t[:id]]
      trainees_metrics << t
    end
    trainees_metrics
  end

  def by_status(status)
    ids = source.send(METHOD_MAP[status.to_sym])
    return [] if ids.empty?
    Trainee.where(id: ids).order(:first, :last)
  end

  def counts_by_status
    counts = {}
    METHOD_MAP.each do |status, method|
      counts[status] = source.send(method).count
    end
    counts
  end

  def source
    @program || @grant
  end
end
