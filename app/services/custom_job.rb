class CustomJob
  def initialize(current_account)
    @current_account = current_account
  end

  def perform
    Account.current_id = @current_account.id
  end
end
