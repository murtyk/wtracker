# frozen_string_literal: true

ReportPolicy = Struct.new(:user, :report) do
  def new?
    user.navigator? || user.admin_or_director?
  end
end
