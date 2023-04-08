# frozen_string_literal: true

# Only Director, Admin and L1 Navs have access
GrantPolicy = Struct.new(:user, :grant) do
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
