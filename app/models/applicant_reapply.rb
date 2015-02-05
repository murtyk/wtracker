class ApplicantReapply < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  attr_accessible :key
  attr_accessor   :salt, :email
  belongs_to :applicant
  belongs_to :account
  belongs_to :grant
end
