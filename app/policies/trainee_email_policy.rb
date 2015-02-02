class TraineeEmailPolicy < Struct.new(:user, :college)
  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def index?
    true
  end

  def show?
    true
  end

  def destroy?
    new?
  end
end
