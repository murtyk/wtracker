# captures trainees to whom a job is forwarded
class JobSharedTo < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  belongs_to :job_share
  belongs_to :trainee
  attr_accessible :trainee_id # permitted
  def sent_to_email
    trainee.email
  end
end
