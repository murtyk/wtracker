# frozen_string_literal: true

CollegePolicy = Struct.new(:user, :college) do
  def new?
    user.admin_access?
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
    new?
  end

  def show?
    new?
  end

  def destroy?
    new? && Klass.unscoped.where(college_id: college.id).empty?
  end
end
