class GrantTraineeStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  default_scope { order(:name) }
  belongs_to :account
  belongs_to :grant
  attr_accessible :name
  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 3, maximum: 100 }
  def is_default?
    id == grant.default_trainee_status_id.to_i
  end
end
