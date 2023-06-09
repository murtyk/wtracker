# frozen_string_literal: true

# job details of a job (job_share) forwarded to trainee
class SharedJob < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :job_share
  belongs_to :account

  has_many :shared_job_statuses
  delegate :company, :location, :comment, :shared_by, :from_user, to: :job_share

  def trainee_status(trainee)
    sjs = shared_job_statuses.where(trainee_id: trainee.id).first
    sjs&.status_name
  end
end
