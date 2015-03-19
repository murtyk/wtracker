class KlassTitlePolicy < Struct.new(:user, :klass_title)
  def new?
    user.admin_or_director? || user.grant_admin?
  end

  def create?
    new?
  end

  def show?
    true
  end

  def destroy?
    new?
  end
end
