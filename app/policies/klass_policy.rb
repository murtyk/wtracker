class KlassPolicy < Struct.new(:user, :klass)
  def trainees?
    user.navigator? || user.admin_or_director?
  end

  def trainees_with_email?
    user.navigator? || user.admin_or_director?
  end

  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def edit?
    new? || (user.navigator? && user.klasses.include?(klass))
  end

  def update?
    edit?
  end

  def index?
    true
  end

  def show?
    new? || user.klasses.include?(klass)
  end

  def destroy?
    new?
  end
end
