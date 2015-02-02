class JobSearchPolicy < Struct.new(:user, :job_search)
  def new?
    user.navigator? || user.admin_or_director?
  end

  def create?
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
    new?
  end

  def destroy?
    new?
  end

  def details?
    new?
  end

  def analyze?
    new?
  end

  def save_companies?
    new?
  end
end
