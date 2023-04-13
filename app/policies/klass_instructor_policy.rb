# frozen_string_literal: true

KlassInstructorPolicy = Struct.new(:user, :klass_instructor) do
  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end
end
