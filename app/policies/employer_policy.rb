class EmployerPolicy < Struct.new(:user, :employer)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    # return false
    new?
  end

  def import?
    user.admin_access?
  end

  def edit?
    return true if user.admin_access?
    user.employer_sources.include? (employer.employer_source)
  end

  def update?
    edit?
  end

  def index?
    new?
  end

  def show?
    edit?
  end

  def destroy?
    edit?
  end

  def show_address?
    edit?
  end

  def show_source?
    edit?
  end

  def show_contacts?
    edit?
  end

  def show_trainee_interactions?
    edit?
  end

  def show_trainee_submits?
    edit?
  end

  def show_hot_jobs?
    edit?
  end

  def show_job_openings?
    edit?
  end

  def show_notes?
    edit?
  end

  def show_klass_interactions?
    edit?
  end
end
