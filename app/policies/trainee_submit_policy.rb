class TraineeSubmitPolicy < Struct.new(:user, :trainee_submit)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end

  def show?
    new?
  end

  def index?
    new?
  end

  def destroy?
    new?
  end
end
