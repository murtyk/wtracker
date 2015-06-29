# collections for selection
module CollectionsHelper
  def accounts_collection
    Account.order(:subdomain)
  end

  def account_types
    Account::TYPES.map { |k, v| [v, k] }
  end

  def account_statuses
    Account::STATUSES.map { |k, v| [v, k] }
  end

  def account_track_trainee_options
    Account::TRACK_TRAINEE_OPTIONS.map { |k, v| [v, k] }
  end

  def applicant_employment_statuses
    Applicant.employment_statuses
  end

  def applicant_statuses
    Applicant.statuses
  end

  def applicant_filter_statuses
    %w(Accepted Declined)
  end

  def applicant_sources
    Applicant.pluck(:source).uniq.sort
  end

  def funding_sources
    FundingSource.all
  end

  def grant_statuses
    Grant::STATUSES.map { |k, v| [v, k] }
  end

  def sectors
    Sector.all
  end

  def hot_job_users
    User.joins(:hot_jobs).select(:id, :first, :last).order(:first, :last).uniq
  end

  def user_roles
    User::ROLES.map { |k, v| [v, k] }
  end

  def user_statuses
    User::STATUSES.map { |k, v| [v, k] }
  end

  def user_copy_job_leads_options
    User::COPY_JOB_LEADS_OPTIONS.map { |k, v| [v, k] }
  end

  def employers_collection
    Employer.order(:name)
  end

  def hot_job_employers
    Employer.joins(:hot_jobs).select(:id, :name).order(:name)
  end

  def employer_sources_collection
    return EmployerSource.order(:name) if current_user.admin_access?
    current_user.employer_sources.order(:name)
  end

  def klass_interaction_statuses
    KlassInteraction::STATUSES.map { |k, v| [v, k] }
  end

  def klass_default_events
    Klass::DEFAULT_EVENTS.map { |v| [v, v] }
  end

  def klass_trainee_statuses
    KlassTrainee::STATUSES.map { |k, v| [v, k] }
  end

  def trainee_interaction_statuses
    TraineeInteraction::STATUSES.map { |k, v| [v, k] }
  end

  def options_for_ampm_select(default_value)
    options_for_select([%w(am am), %w(pm pm)], default_value)
  end

  def trainee_legal_statues
    Trainee::LEGAL_STATUSES.map { |k, v| [v, k] }
  end

  def job_leads_opt_out_reasons
    JobSearchProfile::OPT_OUT_REASONS.map { |k, v| [v, k] }
  end

  def shared_job_statuses
    SharedJobStatus::STATUSES.map { |k, v| [k.to_s.humanize, v] }
  end

  def yes_or_no
    { Yes: true, No: false }
  end
end
