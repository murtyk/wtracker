class KlassPolicy < Struct.new(:user, :klass)
  def trainees?
    user.navigator? || user.admin_or_director?
  end

  def trainees_with_email?
    user.navigator? || user.admin_or_director?
  end

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
