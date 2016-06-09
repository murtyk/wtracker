class ProgramPolicy < Struct.new(:user, :program)
  def new?
    user.admin_access? ||
    (user.navigator? && Grant.current_grant.navigators_can_create_klasses)
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
