# primarily to determine workflow for a trainee
class TraineePortal
  attr_accessor :trainee

  def initialize(t)
    @trainee = t
  end

  def action
    return :pending_data if pending_data?
    return :pending_profile if pending_profile?
    return :pending_resume if pending_resume?
    return :pending_unemployment_proof if pending_unemployment_proof?
    :jobs
  end

  def show_menu_bar?
    action == :jobs
  end

  def pending_data?
    trainee.pending_data?
  end

  def pending_profile?
    # should always have a profile
    unless trainee.job_search_profile
      trainee.create_job_search_profile(account_id: trainee.account_id)
    end

    !trainee.job_search_profile.valid_profile?
  end

  def pending_resume?
    trainee.trainee_files.empty?
  end

  def pending_unemployment_proof?
    applicant = trainee.applicant.reload
    trainee.trainee_files.count == 1 &&
      (applicant.unemployment_proof_initial.blank? ||
       applicant.unemployment_proof_date.blank?)
  end
end
