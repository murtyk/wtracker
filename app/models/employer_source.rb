class EmployerSource < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  attr_accessible :name
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }

  belongs_to :account
  has_many :employers, dependent: :destroy
  has_many :user_employer_sources, dependent: :destroy
  has_many :users, through: :user_employer_sources
end
