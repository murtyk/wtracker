# daily job for creating job search profiles for applicants
class JobSearchProfileJob
  # this is meant to be a daily background task
  def perform
    grants = AutoJobLeads.new.grants_for_auto_leads
    grants.each do |grant|
      next unless grant.trainee_applications?
      Account.current_id = grant.account_id
      Grant.current_id = grant.id
      trainees_without_jsp.each do |trainee|
        create_trainee_address(trainee)
        create_job_search_profile(trainee)
      end
    end
  end

  def create_trainee_address(trainee)
    return if trainee.home_address
    a = trainee.applicant

    TraineeFactory.geocode_applicant(a) unless a.valid_address?
    return unless a.valid_address?

    attrs = TraineeFactory.build_address_attrs(a)
    trainee.create_home_address(attrs)
    Rails.logger.info "AutoJobLeads: created trainee address for #{trainee.name}"
  end

  def create_job_search_profile(trainee)
    return unless trainee.home_address
    a = trainee.applicant
    return unless a.skills

    jsp = trainee.job_search_profile
    attrs = jsp_attrs(trainee)
    attrs[:account_id] = trainee.account_id unless jsp

    jsp.update(attrs) if jsp
    trainee.create_job_search_profile(attrs) unless jsp

    Rails.logger.info "AutoJobLeads: created(updated) jsp for #{trainee.name}"
  end

  def trainees_without_jsp
    t_ids = Applicant.pluck(:trainee_id).compact
    t_ids -= JobSearchProfile.where(trainee_id: t_ids)
             .where.not(skills: nil)
             .pluck(:trainee_id)
    Trainee.includes(:home_address, :applicant).where(id: t_ids)
  end

  def jsp_attrs(trainee)
    location = trainee_location(trainee)
    a = trainee.applicant
    {
      skills:   a.skills,
      location: location,
      zip:      trainee.home_address.zip,
      distance: 20
    }
  end

  def trainee_location(trainee)
    trainee.home_address.city + ',' + trainee.home_address.state
  end
end
