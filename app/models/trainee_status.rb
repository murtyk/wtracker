class TraineeStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }

  attr_accessible :grant_trainee_status_id, :notes
  belongs_to :account
  belongs_to :grant
  belongs_to :grant_trainee_status
  belongs_to :trainee

  delegate :name, to: :grant_trainee_status
end
