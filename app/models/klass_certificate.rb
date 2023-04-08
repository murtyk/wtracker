# captures the certificates a class issues on completion
class KlassCertificate < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  belongs_to :klass
  belongs_to :certificate_category

  validates :name, presence: true, length: { minimum: 3, maximum: 80 }

  delegate :code, to: :certificate_category, prefix: true, allow_nil: true

  def code
    certificate_category_code
  end
end
