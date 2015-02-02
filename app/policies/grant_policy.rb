class GrantPolicy < Struct.new(:user, :grant)
  def edit?
    user.admin_or_director?
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
