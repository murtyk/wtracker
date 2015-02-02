class AssessmentPolicy < Struct.new(:user, :assessment)
  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end

  def index?
    true
  end
end
