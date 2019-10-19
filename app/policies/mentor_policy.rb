class MentorPolicy < Struct.new(:user, :trainee_service)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end

  def show?
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

  def destroy?
    new?
  end
end
