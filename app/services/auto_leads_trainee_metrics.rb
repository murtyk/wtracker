class AutoLeadsTraineeMetrics
  attr_reader :trainee_ids

  def initialize(trainee_ids)
    @trainee_ids = trainee_ids
  end

  def metrics(trainees_list)
    trainees_list.map do |id, first, last|
      trainee_metric(id, first + ' ' + last)
    end
  end

  def trainee_metric(id, name)
    {
      id: id,
      name: name,
      valid_profile:        valid_profile?(id),
      leads_count:          job_leads_count(id),
      viewed_count:         jobs_viewed_count(id),
      applied_count:        jobs_applied_count(id),
      not_interested_count: not_interested_count(id)
    }
  end

  def trainees_valid
    return @trainee_valid if @trainees_valid

    t_ids = JobSearchProfile
             .where(trainee_id: trainee_ids)
             .where('skills is not null')
             .pluck(:trainee_id)

    yeses = [true] * t_ids.size

    @trainee_valid = Hash[t_ids.zip(yeses)]
  end

  def valid_profile?(trainee_id)
    trainees_valid[trainee_id]
  end

  def asjs
    @asjs ||= AutoSharedJob.where(trainee_id: trainee_ids)
  end

  def job_leads_count(id)
    @job_leads_counts ||= asjs.group(:trainee_id).count
    @job_leads_counts[id]
  end

  def leads_count_by_status
    @leads_count_by_status ||= asjs.group(:trainee_id, :status).count
  end

  def jobs_viewed_count(id)
    leads_count_by_status[[id, 1]].to_i +
      leads_count_by_status[[id, 2]].to_i +
      leads_count_by_status[[id, 3]].to_i
  end

  def jobs_applied_count(id)
    leads_count_by_status[[id, 2]]
  end

  def not_interested_count(id)
    leads_count_by_status[[id, 3]].to_i + leads_count_by_status[[id, 4]].to_i
  end
end