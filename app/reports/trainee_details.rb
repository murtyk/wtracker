include UtilitiesHelper
# provides details information on a trainee
# for trainee details with placement
class TraineeDetails < DelegateClass(Trainee)
  attr_reader :hired, :hired_interaction
  def initialize(obj)
    super(obj)
    @hired_interaction = hired_employer_interaction
    if @hired_interaction
      @hired = true
      @hired_employer = @hired_interaction.employer
    end
  end

  def hired_employer_interaction
    super
  end

  def hired_employer
    @hired_employer
  end

  def hired_employer_name
    @hired_employer && @hired_employer.name
  end

  def employer_location
    @hired_employer && @hired_employer.location
  end

  def job_start_date
    hired_interaction && hired_interaction.start_date.to_s
  end

  def pay
    hired_interaction && hired_interaction.hire_salary
  end

  def status_in_klass(klass)
    KlassTrainee::STATUSES[klass_trainees.where(klass_id: klass.id).first.status]
  end

  def land_no
    format_phone_no(super)
  end

  def mobile_no
    format_phone_no(super)
  end

  def gender
    super.to_i == 1 ? 'M' : 'F'
  end

  def veteran
    super ? 'x' : ''
  end

  def dob
    super.to_s
  end
end
