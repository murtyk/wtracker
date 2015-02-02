class TraineePolicy < Struct.new(:user, :trainee)
  def new?
    return false if Grant.find(Grant.current_id).trainee_applications?
    user.admin_or_director? || user.navigator?
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
