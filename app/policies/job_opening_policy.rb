class JobOpeningPolicy < Struct.new(:user, :job_opening)
  def new?
    user.admin_or_director? || user.navigator?
  end

  def create?
    new?
  end
end
