# a trainee assigned to a class
# trainee has a status in a class
class KlassTrainee < ActiveRecord::Base
  STATUSES = { 1 => 'Enrolled', 2 => 'Completed',
               3 => 'Dropped', 4 => 'Placed', 5 => 'Continuing Education' }

  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :klass
  belongs_to :trainee
  attr_accessible :status, :trainee_id, :klass_id, :notes, :account_id
  attr_accessor :employer_name, :employer_id,
                :start_date, :hire_title, :hire_salary

  after_initialize :default_values

  def name
    trainee.name
  end

  def hired?
    status == 4
  end

  def hired_employer
    Employer.find(@employer_id) if hired? && @employer_id
  end

  def klass_name
    klass.name
  end

  def college_name_location
    klass.college_name_location
  end

  private

  EMP_ATTRS = %w(employer_id employer_name hire_title hire_salary start_date)
  def copy_employer_interaction_details
    if id && hired? && trainee
      ei = trainee.hired_employer_interaction
      return unless ei
      EMP_ATTRS.each { |attr| send("#{attr}=", ei.send(attr)) }
    end
  end

  def default_values
    self.status ||= 1
    copy_employer_interaction_details
  end
end
