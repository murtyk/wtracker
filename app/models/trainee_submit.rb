# frozen_string_literal: true

# either trainee directly applied for a job
# or navigator forwarded resume
class TraineeSubmit < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :trainee
  belongs_to :employer
  belongs_to :email

  validates :employer, presence: true
  validates :title, presence: true
  validates :applied_on, presence: true

  delegate :name, to: :employer, prefix: true

  def by_trainee?
    email_id.nil?
  end
end
