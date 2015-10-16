class CertificateCategory < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:name) }

  belongs_to :account
  belongs_to :grant

  validates_presence_of :code
  validates_presence_of :name

  has_many :klass_certificates
  has_many :klasses, through: :klass_certificates

  def destroyable?
    !klass_certificates.any?
  end
end
