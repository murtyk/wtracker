# frozen_string_literal: true

AutoSharedJobPolicy = Struct.new(:user, :auto_shared_job) do
  def edit?
    true
  end

  def update?
    true
  end
end
