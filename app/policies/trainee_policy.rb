class TraineePolicy < Struct.new(:user, :trainee)
  def new?
    return false if grant.trainee_applications?
    user.admin_access? || (user.navigator? && user.grants.include?(grant))
  end

  def create?
    new?
  end

  def import?
    new?
  end

  def edit?
    user.admin_or_director? || user.navigator?
  end

  def disable?
    edit?
  end

  def update?
    edit?
  end

  def update_disable?
    update?
  end

  def import_updates?
    grant.trainee_applications? && edit?
  end

  def index?
    show?
  end

  def show?
    true
  end

  def destroy?
    user.director?
  end

  def mapview?
    show?
  end

  def grant
    @grant ||= Grant.find(Grant.current_id)
  end
end
