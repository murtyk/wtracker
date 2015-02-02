# grant specific managed through settings
# used for applicant grant
class UnemploymentProof < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  default_scope { order(:created_at) }
  belongs_to :account
  belongs_to :grant
  attr_accessible :name
  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 3, maximum: 100 }
  def self.collection_options
    UnemploymentProof.pluck(:name)
  end
end
