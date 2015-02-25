class TraineePolicy < Struct.new(:user, :trainee)
  def new?
    grant = Grant.find(Grant.current_id)
    return false if grant.trainee_applications?
    user.admin_access? || (user.navigator? && user.grants.include?(grant))
  end

  def create?
    new?
  end

  def edit?
    user.admin_or_director? || user.navigator?
  end

  def update?
    edit?
  end

  def index?
    show?
  end

  def show?
    true
  end

  def destroy?
    new?
  end

  def mapview?
    show?
  end
end
