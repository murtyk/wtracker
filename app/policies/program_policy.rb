# frozen_string_literal: true

ProgramPolicy = Struct.new(:user, :program) do
  def new?
    user.admin_access? ||
      user.grant_admin? ||
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
