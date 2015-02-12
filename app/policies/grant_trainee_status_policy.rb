class GrantTraineeStatusPolicy < Struct.new(:user, :grant_trainee_status)
  def new?
    user.admin_access?
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
end
