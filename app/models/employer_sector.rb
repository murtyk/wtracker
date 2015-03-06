# an employer can be in many sectors
class EmployerSector < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :employer
  belongs_to :sector
  attr_accessible :sector_id, :account_id, :employer_id

  delegate :name, to: :sector, prefix: true, allow_nil: true
end
