# reference data. trainee funding.
class FundingSource < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  belongs_to :account
  belongs_to :grant
  attr_accessible :name
  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 3, maximum: 50 }

  has_many :trainees
end
