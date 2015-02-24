# Applicable statuses for trainees in a grant
# Defined through user settings
# One of them can be defined as default for the grant
class GrantTraineeStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  default_scope { order(:name) }

  attr_accessible :name

  belongs_to :account
  belongs_to :grant
  has_many :trainees, foreign_key: :gts_id

  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 3, maximum: 100 }

  def default?
    id == grant.default_trainee_status_id.to_i
  end
end
