class TraineeAutoLeadStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  belongs_to :account
  belongs_to :grant
  belongs_to :trainee
end
