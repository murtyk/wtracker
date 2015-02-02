class KlassTraineePolicy < Struct.new(:user, :klass_trainee)
  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def edit?
    new? || (user.navigator? && user.klasses.include?(klass_trainee.klass))
  end

  def update?
    edit?
  end

  def show?
    edit? || user.klasses.include?(klass_trainee.klass)
  end

  def destroy?
    new?
  end
end
