# THIS MODEL NOT REQUIRED ANY LONGER. WE SHOULD GET RID OFF IT.
# race of the student. optional field
class TraineeRace < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  belongs_to :race
end
