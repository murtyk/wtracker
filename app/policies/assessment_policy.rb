# frozen_string_literal: true

AssessmentPolicy = Struct.new(:user, :assessment) do
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
    new? && assessment.trainees.empty?
  end

  def index?
    true
  end
end
