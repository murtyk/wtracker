class CertificateCategory < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:name) }

  belongs_to :account
  belongs_to :grant

  validates :name,
            presence: { message: 'name can not be blank.' },
            length: { minimum: 2, maximum: 50 }

  validates :code,
            presence: { message: 'code can not be blank.' },
            length: { minimum: 1, maximum: 50 }

  has_many :klass_certificates
  has_many :klasses, through: :klass_certificates

  def destroyable?
    !klass_certificates.any?
  end
end
