class AssessmentPolicy < Struct.new(:user, :assessment)
  def new?
    user.director?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def destroy?
    new?
  end

  def index?
    true
  end
end
