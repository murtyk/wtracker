# frozen_string_literal: true

HotJobPolicy = Struct.new(:user, :hot_job) do
  def new?
    true
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
    new?
  end

  def show?
    new?
  end

  def destroy?
    new?
  end
end
