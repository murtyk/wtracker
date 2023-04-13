# frozen_string_literal: true

FundingSourcePolicy = Struct.new(:user, :funding_source) do
  def new?
    user.director?
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

  def index?
    user.admin_access?
  end

  def show?
    user.admin_access?
  end

  def destroy?
    new?
  end
end
