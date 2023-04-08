# frozen_string_literal: true

AccountPolicy = Struct.new(:user, :account) do
  def new?
    false
  end

  def create?
    false
  end

  def edit?
    user.director?
  end

  def update?
    user.director?
  end

  def destroy?
    false
  end

  def index?
    false
  end
end
