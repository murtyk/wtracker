# an employer can be interested in a trainee
# may interview, offer and hire
class TraineeInteraction < ActiveRecord::Base
  STATUSES = { 1 => 'Interested', 2 => 'Interview', 3 => 'Offer',
               4 => 'Hired', 5 => 'Declined' }

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  belongs_to :employer
  belongs_to :trainee
  attr_accessible :trainee_id, :employer_id, :comment, :status, :company, :employer_name,
                  :interview_date, :interviewer,
                  :offer_date, :offer_salary, :offer_title,
                  :start_date, :hire_salary, :hire_title

  attr_accessor :klass_id, :trainee_ids, :employer_name

  validates :status, inclusion: { in: 1..5, message: 'invalid status code' }

  before_save :cb_before_save

  def employer_name
    (employer_id.to_i > 0 && employer && employer.name) || company
  end

  def employer_location
    employer_id.to_i > 0 && employer && employer.location
  end

  def trainee_name
    trainee && trainee.name
  end

  def klass_names
    trainee && trainee.klass_names
  end

  def unhire
    self.start_date   = nil
    self.hire_salary  = nil
    self.hire_title   = nil
    save
  end

  def status_name
    STATUSES[status]
  end

  def delete_confirm_message
    return 'Are you sure?' if status == 1
    "#{status_name} status related data will be lost. Are you sure?"
  end

  def short_comment
    comment && "Comments: #{comment.truncate(40)}"
  end

  private

  def cb_before_save
    return change_to_hired if hired_data_set?

    if !offer_title.blank?
      self.status = status_code('Offer')
    elsif !interviewer.blank?
      self.status = status_code('Interview')
    else
      self.status ||= status_code('Interested')
    end
  end

  def hired_data_set?
    !hire_title.blank? || start_date || !hire_salary.blank?
  end

  def change_to_hired
    self.status = status_code('Hired')
    # change the status for trainee in the klass to placed
    trainee.klass_trainees.each do |kt|
      kt.status = 4
      kt.save
    end
  end

  def status_code(s)
    STATUSES.key(s)
  end
end
