# frozen_string_literal: true

TraineeAssessmentPolicy = Struct.new(:user, :trainee_assessment) do
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end

  def show?
    user.role < 4
  end

  def index?
    user.role < 4
  end

  def destroy?
    new?
  end
end
