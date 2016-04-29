# a trainee assigned to a class
# trainee has a status in a class
class KlassTrainee < ActiveRecord::Base
  STATUSES = { 1 => 'Enrolled', 2 => 'Completed',
               3 => 'Dropped', 4 => 'Placed', 5 => 'Continuing Education' }

  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :klass
  belongs_to :trainee

  attr_accessor :employer_name, :employer_id,
                :start_date, :completion_date, :hire_title,
                :hire_salary, :comment,
                :ti_status, :uses_trained_skills

  before_save :determine_status
  after_initialize :default_values

  delegate :name, :name_fs, to: :trainee
  delegate :name, to: :klass, prefix: true
  delegate :college_name_location, to: :klass

  def hired?
    status == 4
  end

  def hired_employer_interaction
    trainee.hired_employer_interaction
  end

  def hired_employer
    Employer.find(@employer_id) if hired? && @employer_id
  end

  def status_text
    KlassTrainee::STATUSES[status]
  end

  private

  EMP_ATTRS = %w(employer_id employer_name hire_title
                 hire_salary start_date comment)
  def copy_employer_interaction_details
    return unless id && hired? && trainee
    ei = trainee.hired_employer_interaction
    return unless ei
    EMP_ATTRS.each { |attr| send("#{attr}=", ei.send(attr)) }
  end

  def default_values
    self.status ||= 1
    # copy_employer_interaction_details
  end

  def determine_status
    self.status = 4 if trainee && trainee.hired?
  end
end
