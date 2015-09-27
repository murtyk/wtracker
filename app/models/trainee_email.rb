# emails sent to trainees
class TraineeEmail < ActiveRecord::Base
  serialize :trainee_ids
  serialize :trainee_names
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :user
  belongs_to :klass

  attr_accessor :use_job_leads_email

  validates :subject, presence: true, length: { minimum: 5 }
  validates :content, presence: true, length: { minimum: 5 }
  validates :trainee_ids, presence: true
  validates :klass_id, presence: true

  def sender
    "#{user.name}<#{user.email}>"
  end

  def sender_email_address
    user.email
  end

  def klass_name
    klass && klass.name
  end
end
