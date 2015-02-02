class CollegePolicy < Struct.new(:user, :college)
  def new?
    user.admin_or_director? || user.grant_admin?
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
    true
  end

  def show?
    true
  end

  def destroy?
    new? && Klass.unscoped.where(college_id: college.id).empty?
  end
end
