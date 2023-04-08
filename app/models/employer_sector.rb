# frozen_string_literal: true

# an employer can be in many sectors
class EmployerSector < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :employer
  belongs_to :sector

  delegate :name, to: :sector, prefix: true, allow_nil: true
end
