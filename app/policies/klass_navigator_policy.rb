# frozen_string_literal: true

KlassNavigatorPolicy = Struct.new(:user, :klass_navigator) do
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
