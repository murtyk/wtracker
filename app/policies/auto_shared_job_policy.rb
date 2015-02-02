class AutoSharedJobPolicy < Struct.new(:user, :auto_shared_job)
  def edit?
    true
  end

  def update?
    true
  end
end
