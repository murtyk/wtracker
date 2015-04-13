# an employer can be interested in a trainee
# may interview, offer and hire
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

  attr_accessible :trainee_id, :employer_id, :comment, :status, :company, :employer_name,
                  :interview_date, :interviewer,
                  :offer_date, :offer_salary, :offer_title,
                  :start_date, :hire_salary, :hire_title, :termination_date

  attr_accessor :klass_id, :trainee_ids, :employer_name

  before_save :cb_before_save

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

  private

  def cb_before_save
    self.status ||= 4
  end
end
