# notes captured on an employer
class EmployerNote < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :employer
  belongs_to :account
  attr_accessible :note, :employer_id # permitted

  validates :note, presence: true, length: { minimum: 3 }
end
