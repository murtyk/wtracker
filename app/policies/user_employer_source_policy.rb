class UserEmployerSourcePolicy < Struct.new(:user, :employer_sector)
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
