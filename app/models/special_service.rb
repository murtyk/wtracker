# user defined grant specific special services
# applicant selects one or more
class SpecialService < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:created_at) }

  belongs_to :account
  belongs_to :grant

  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 3, maximum: 50 }

  has_many :applicant_special_services, dependent: :destroy
  has_many :applicants, through: :applicant_special_services
end
