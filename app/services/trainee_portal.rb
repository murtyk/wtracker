# frozen_string_literal: true

# primarily to determine workflow for a trainee
class TraineePortal
  attr_accessor :trainee

  def initialize(t)
    @trainee = t
  end

  def action
    return :closed if trainee.grant.status == 3
    return :jobs if skip_data_capture?
    return :pending_data if pending_data?
    return :pending_profile if pending_profile?
    return :pending_resume if pending_resume?
    return :pending_unemployment_proof if pending_unemployment_proof?

    :jobs
  end

  def show_menu_bar?
    action == :jobs
  end

  def skip_data_capture?
    trainee.grant.skip_trainee_data_capture
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
    return false if file_exists?('Resume')

    applicant = trainee.applicant.reload

    !applicant.skip_resume
  end

  def pending_unemployment_proof?
    return false if file_exists?('Unemployment Proof')

    ap = trainee.applicant.reload

    ap.unemployment_proof_initial.blank? || ap.unemployment_proof_date.blank?
  end

  def file_exists?(notes)
    trainee.trainee_files.where('notes ilike ?', notes).first
  end
end
