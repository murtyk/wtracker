# frozen_string_literal: true

ContactPolicy = Struct.new(:user, :contact) do
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end

  def index?
    new?
  end
end
