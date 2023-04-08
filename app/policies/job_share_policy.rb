# frozen_string_literal: true

JobSharePolicy = Struct.new(:user, :job_share) do
  def new?
    user.navigator? || user.admin_or_director?
  end

  def new_multiple?
    new?
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
    true
  end

  def show?
    true
  end
end
