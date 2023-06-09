# frozen_string_literal: true

# after a job is forwarded to a trainee, status can be tracked
# has trainee viewed the job? applied? etc.
class SharedJobStatus < ApplicationRecord
  STATUSES = { VIEWED: 1, APPLIED: 2, NOT_APPLIED: 3, NO_MATCH: 4 }.freeze

  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :trainee
  belongs_to :shared_job

  delegate :title, :location, :company, :comment, :details_url, :from_user,
           to: :shared_job

  def need_status_feedback?
    !(status && status > 1)
  end

  def update_status(new_status)
    self.status ||= 0
    return unless self.status.zero? || new_status > STATUSES[:VIEWED]

    self.status = new_status
    save
  end

  def clicked(params_key)
    update_status STATUSES[:VIEWED] if params_key == key
    params_key == key
  end

  def status_name
    status.to_i.positive? && STATUSES.key(self.status).to_s.humanize
  end

  def to_email
    trainee.email
  end

  delegate :name, to: :trainee, prefix: true

  def job_details_url
    shared_job.details_url
  end

  def self.search(filters)
    return [] unless filters

    klass_id   = filters[:klass_id].to_i
    trainee_id = filters[:trainee_id].to_i

    return [] unless trainee_id.positive? || klass_id.positive?

    ord = 'shared_job_statuses.created_at desc'

    if trainee_id.positive?
      return includes(:trainee)
             .where(trainee_id: trainee_id).order(ord)
    end

    includes(trainee: :klass_trainees)
      .where(klass_trainees: { klass_id: klass_id }).order(ord)
  end
end
