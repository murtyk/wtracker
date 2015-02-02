# race of the student. optional field
class TraineeRace < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  belongs_to :race
  attr_accessible :race_id, :account_id, :trainee_id
  # attr_accessible :title, :body
end
