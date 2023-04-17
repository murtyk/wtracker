# frozen_string_literal: true

# reference list of assessments of a class
class Assessment < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:name) }

  belongs_to :account
  belongs_to :grant

  has_many :trainee_assessments, dependent: :destroy
  has_many :trainees, through: :trainee_assessments

  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 50 }

  def self.ransackable_attributes(auth_object = nil)
    ["account_id", "administered_by", "created_at", "grant_id", "id", "name", "updated_at"]
  end
end
