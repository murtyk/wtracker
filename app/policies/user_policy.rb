class UserPolicy < Struct.new(:user, :otheruser)
  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def edit?
    user.director? ||
    user == otheruser ||
    (user.admin? && !otheruser.admin_or_director?) ||
    (user.grant_admin?  && !otheruser.admin_or_director?)
  end

  def update?
    edit?
  end

  def index?
    new?
  end

  def show?
    edit?
  end

  def destroy?
    new?
  end
end
