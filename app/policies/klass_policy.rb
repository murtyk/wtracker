# frozen_string_literal: true

KlassPolicy = Struct.new(:user, :klass) do
  def trainees?
    user.navigator? ||
      user.grant_admin? ||
      user.admin_or_director?
  end

  def trainees_with_email?
    trainees?
  end

  def new?
    user.admin_access? ||
      user.grant_admin? ||
      (user.navigator? && Grant.current_grant.navigators_can_create_klasses)
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    edit?
  end

  def index?
    true
  end

  def show?
    new? || user.grants.include?(klass.grant) || user.klasses.include?(klass)
  end

  def destroy?
    user.director?
  end
end
