# after a job is forwarded to a trainee, status can be tracked
# has trainee viewed the job? applied? etc.
class SharedJobStatus < ActiveRecord::Base
  STATUSES = { VIEWED: 1, APPLIED: 2, NOT_APPLIED: 3, NO_MATCH: 4 }

  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :trainee
  belongs_to :shared_job
  attr_accessible :feedback, :key, :status, :trainee_id
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
    status.to_i > 0 && STATUSES.key(self.status).to_s.humanize
  end

  def to_email
    trainee.email
  end

  def trainee_name
    trainee.name
  end

  def job_details_url
    shared_job.details_url
  end

  def self.search(filters)
    return [] unless filters

    klass_id   = filters[:klass_id].to_i
    trainee_id = filters[:trainee_id].to_i

    return [] unless trainee_id > 0 || klass_id > 0

    ord = 'shared_job_statuses.created_at desc'

    return includes(:trainee)
      .where(trainees_id: trainee_id).order(ord) if trainee_id > 0

    includes(trainee: :klass_trainees)
      .where(klass_trainees: { klass_id: klass_id }).order(ord)
  end
end
