# authorizations for user object
class UserPolicy < Struct.new(:user, :otheruser)
  def new?
    user.admin_access?
  end

  def create?
    new?
  end

  def edit?
    return true if user.director? || user == otheruser
    return false if otheruser.director?
    can_edit_other?
  end

  def update?
    edit?
  end

  def index?
    new?
  end

  def show?
    user.admin_access? || (user == otheruser)
  end

  def destroy?
    user.director? && otheruser.deletable?
  end

  private

  def can_edit_other?
    (user.admin? && !otheruser.admin?) ||
      (user.admin_access?  && !otheruser.admin_or_director?)
  end
end
