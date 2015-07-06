# Only Director, Admin and L1 Navs have access
class GrantPolicy < Struct.new(:user, :grant)
  def edit?
    user.director?
  end

  def update?
    edit?
  end

  def show?
    user.admin_access?
  end

  def index?
    user.admin_access?
  end
end
