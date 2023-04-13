# frozen_string_literal: true

# grant specific managed through settings
# used for applicant grant
class UnemploymentProof < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:created_at) }
  belongs_to :account
  belongs_to :grant

  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 3, maximum: 100 }
  def self.collection_options
    UnemploymentProof.pluck(:name)
  end
end
