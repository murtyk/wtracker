class KlassCertificatePolicy < Struct.new(:user, :klass_certificate)
  def new?
    user.admin_access? || user.navigator?
  end

  def create?
    new?
  end
end
