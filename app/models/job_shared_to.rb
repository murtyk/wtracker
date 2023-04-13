# frozen_string_literal: true

# captures trainees to whom a job is forwarded
class JobSharedTo < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  belongs_to :job_share
  belongs_to :trainee

  def sent_to_email
    trainee.email
  end
end
