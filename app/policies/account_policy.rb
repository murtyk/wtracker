class AccountPolicy < Struct.new(:user, :account)
  def new?
    false
  end

  def create?
    false
  end

  def edit?
    user.director?
  end

  def update?
    user.director?
  end

  def destroy?
    false
  end

  def index?
    false
  end
end
