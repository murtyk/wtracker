# captures the certificates a class issues on completion
class KlassCertificate < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  belongs_to :klass
  attr_accessible :description, :name, :klass_id # permitted

  validates :name, presence: true, length: { minimum: 3, maximum: 80 }
end
