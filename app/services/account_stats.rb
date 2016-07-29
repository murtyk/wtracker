# account metrics for opero admin
class AccountStats
  attr_reader :account, :users_count, :grants

  def initialize(id)
    @account = Account.find(id)
    @users_count = User.unscoped.where(account_id: id).count
    generate
  end

  def header
    account.name
  end

  def generate
    @grants = []

    Grant.unscoped.where(account_id: account.id).each do |grant|
      g = OpenStruct.new
      g[:name] = grant.name
      g[:programs_count] = Program.unscoped.where(grant_id: grant.id).count
      g[:classes_count] = Klass.unscoped.where(grant_id: grant.id).count
      g[:trainees_count] = Trainee.unscoped.where(grant_id: grant.id).count

      grants << g
    end
  end
end
