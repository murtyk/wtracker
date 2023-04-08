# frozen_string_literal: true

KlassCertificatePolicy = Struct.new(:user, :klass_certificate) do
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
