# frozen_string_literal: true

# reference data. trainee funding.
class FundingSource < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  belongs_to :account
  belongs_to :grant

  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 2, maximum: 50 }

  has_many :trainees
end
