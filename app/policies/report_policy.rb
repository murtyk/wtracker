class ReportPolicy < Struct.new(:user, :report)
  def new?
    user.navigator? || user.admin_or_director?
  end
end
