# mixin to extend Grant model
# provides methods for auto leads metrics/dashboard
module AutoLeadsMetrics
  def scheduled_classes
    klasses.where('DATE(start_date) > ?', Time.now.to_date).order('start_date')
  end

  def ongoing_classes
    klasses.joins(:college)
      .where('DATE(start_date) <= ? and DATE(end_date) >= ?',
             Time.now.to_date, Time.now.to_date)
      .order('colleges.name')
      .order('start_date desc')
  end

  def completed_classes
    klasses.where('DATE(end_date) < ?', Time.now.to_date)
      .order('start_date desc')
  end

  def enrolled_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.enrolled_count.to_i }.inject(:+)
  end

  def dropped_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.dropped_count.to_i }.inject(:+)
  end

  def completed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.completed_count.to_i }.inject(:+)
  end

  def continuing_education_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.continuing_education_count.to_i }.inject(:+)
  end

  def placed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.placed_count.to_i }.inject(:+)
  end

  def not_placed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.not_placed_count.to_i }.inject(:+)
  end

  def placement_rate(klass_status)
    # completed is our target for placement, exclude continuing education

    dividend = placed_count(klass_status) + continuing_education_count(klass_status)
    divisor  = divider(klass_status)
    divisor > 0 ? (dividend.to_f * 100 / divisor).round(0).to_s + '%' : ''
  end

  def divider(klass_status)
    not_placed_count(klass_status) +
      placed_count(klass_status) +
      continuing_education_count(klass_status)
  end

  def trainees_with_valid_job_search_profiles
    JobSearchProfile.where(trainee_id: trainee_ids)
      .where('skills is not null').pluck(:trainee_id)
  end

  def trainees_pending_job_search_profiles
    trainee_ids - trainees_with_valid_job_search_profiles
  end

  def job_leads_sent_count
    AutoSharedJob.unscoped.where(trainee_id: trainee_ids).count
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

  def trainee_ids
    return @trainee_ids if @trainee_ids
    klass_ids = klasses.pluck(:id)
    @trainee_ids = KlassTrainee.unscoped.select(:trainee_id)
                   .where(klass_id: klass_ids).pluck(:trainee_id).uniq
    @trainee_ids
  end

  def trainees_opted_out
    JobSearchProfile.where(opted_out: true, trainee_id: trainee_ids).pluck(:trainee_id)
  end
end
