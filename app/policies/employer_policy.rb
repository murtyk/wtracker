class EmployerPolicy < Struct.new(:user, :employer)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    # return false
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def index?
    new?
  end

  def show?
    true
  end

  def destroy?
    new?
  end

  def show_address?
    new?
  end

  def show_source?
    new?
  end

  def show_contacts?
    new?
  end

  def show_trainee_interactions?
    new?
  end

  def show_trainee_submits?
    new?
  end

  def show_job_openings?
    new?
  end

  def show_notes?
    new?
  end

  def show_klass_interactions?
    true
  end
end
