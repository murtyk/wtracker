# frozen_string_literal: true

TraineeFilePolicy = Struct.new(:user, :trainee_file) do
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end

  def show?
    new?
  end

  def index?
    true
  end
end
