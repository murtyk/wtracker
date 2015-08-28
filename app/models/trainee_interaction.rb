# an employer hires a trainee or terminates employment
class TraineeInteraction < ActiveRecord::Base
  STATUSES = { 4 => 'No OJT', 5 => 'OJT Enrolled', 6 => 'OJT Completed' }
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  belongs_to :employer
  belongs_to :trainee

  # delegate :name,        to: :employer, prefix: true, allow_nil: true
  delegate :location,    to: :employer, prefix: true, allow_nil: true
  delegate :name,        to: :trainee,  prefix: true, allow_nil: true
  delegate :klass_names, to: :trainee, allow_nil: true

  # permitted
  attr_accessible :trainee_id, :employer_id, :comment, :status,
                  :company, :employer_name,
                  :start_date, :hire_salary, :hire_title, :termination_date

  attr_accessor :klass_id, :trainee_ids, :employer_name

  before_save :cb_before_save
  after_save :cb_after_save

  def hired?
    termination_date.nil? && (status == 4 || status == 6)
  end

  def terminated?
    termination_date
  end

  def ojt_enrolled?
    status == 5
  end

  def status_name
    return 'Terminated' if termination_date
    return "Hired (#{ojt_status})" if hired?
    ojt_status
  end

  def ojt_status
    STATUSES[status]
  end

  def short_comment
    comment && "Comments: #{comment.truncate(40)}"
  end

  def employer_name
    employer && employer.name
  end

  def update_trainee_status
    # determine if this ti is the latest ti for the trainee
    # do not use trainee.trainee_interactions since it changes the default order
    latest_ti = TraineeInteraction.where(trainee_id: trainee.id).last
    return unless latest_ti.id == id

    code = status == 6 ? 4 : status
    code = 0 if termination_date

    trainee.update(status: code)
  end

  private

  def cb_before_save
    self.status ||= 4
  end

  def cb_after_save
    update_trainee_status
  end
end
