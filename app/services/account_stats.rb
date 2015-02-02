# account metrics for opero admin
class AccountStats
  def self.generate(id)
    stats       = OpenStruct.new
    account     = Account.find(id)
    stats.name  = account.name

    { employers: Employer, grants: Grant, programs: Program,
      klasses: Klass, trainees: Trainee, users: User }.each do |k, v|
      stats[k]   = v.unscoped.where(account_id: id).count
    end
    stats
  end
end
