# frozen_string_literal: true

UiVerifiedNotePolicy = Struct.new(:user, :ui_verified_note) do
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
