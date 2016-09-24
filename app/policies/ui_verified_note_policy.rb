class UiVerifiedNotePolicy < Struct.new(:user, :ui_verified_note)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end

  def show?
    new?
  end

  def edit?
    false
  end

  def update?
    false
  end

  def index?
    new?
  end

  def destroy?
    new?
  end
end
