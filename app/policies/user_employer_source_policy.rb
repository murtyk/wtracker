# frozen_string_literal: true

UserEmployerSourcePolicy = Struct.new(:user, :employer_sector) do
  def new?
    user.admin_access?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end
end
