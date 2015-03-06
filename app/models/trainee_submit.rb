# either trainee directly applied for a job
# or navigator forwarded resume
class TraineeSubmit < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :trainee
  belongs_to :employer
  belongs_to :email
  attr_accessible :title, :trainee_id, :employer_id, :applied_on

  validates :employer, presence: true
  validates :title, presence: true
  validates :applied_on, presence: true

  delegate :name, to: :employer, prefix: true

  def by_trainee?
    email_id.nil?
  end
end
