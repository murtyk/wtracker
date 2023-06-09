# frozen_string_literal: true

# employer belongs to one source
class EmployerSource < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }

  belongs_to :account
  has_many :employers, dependent: :destroy
  has_many :user_employer_sources, dependent: :destroy
  has_many :users, through: :user_employer_sources
end
