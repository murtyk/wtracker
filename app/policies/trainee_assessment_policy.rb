class TraineeAssessmentPolicy < Struct.new(:user, :trainee_assessment)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    user.role < 4
  end

  def show?
    user.role < 4
  end

  def index?
    user.role < 4
  end

  def destroy?
    user.role < 4
  end
end
