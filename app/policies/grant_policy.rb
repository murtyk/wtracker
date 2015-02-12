class GrantPolicy < Struct.new(:user, :grant)
  def edit?
    user.admin_access?
  end

  def update?
    edit?
  end

  def show?
    edit? ||
    user.navigator? && user.active_grants.include?(grant)
  end

  def index?
    edit? || user.navigator?
  end
end
