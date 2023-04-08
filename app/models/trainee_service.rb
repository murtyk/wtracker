# In grants that have trainee applications,
#   many services can be provided to a trainee.
class TraineeService < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  validates :name, presence: true
  validates :start_date, presence: true

  belongs_to :trainee
end
