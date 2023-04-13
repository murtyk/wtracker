# frozen_string_literal: true

JobOpeningPolicy = Struct.new(:user, :job_opening) do
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end
end
