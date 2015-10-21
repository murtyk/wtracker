class KlassCertificatePolicy < Struct.new(:user, :klass_certificate)
  def new?
    user.admin_access? || user.navigator?
  end

  def edit?
    new?
  end

  def update?
    create?
  end

  def create?
    new?
  end

  def destroy?
    create?
  end
end
