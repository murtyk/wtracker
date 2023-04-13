# frozen_string_literal: true

# notes captured on an employer
class EmployerNote < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :employer
  belongs_to :account

  validates :note, presence: true, length: { minimum: 3 }
end
