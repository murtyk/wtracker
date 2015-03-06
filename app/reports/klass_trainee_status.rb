# trainee and full status information
class KlassTraineeStatus < DelegateClass(KlassTrainee)
  attr_reader :hired_employer, :hired

  delegate :name, to: :hired_employer, prefix: true
  delegate :id, to: :klass, prefix: true
  delegate :funding_source_name, to: :trainee

  def initialize(obj)
    super(obj)
    @hired_interaction = trainee.hired_employer_interaction
    return unless @hired_interaction
    @hired = true
    @hired_employer = @hired_interaction.employer
  end

  def status
    KlassTrainee::STATUSES[super]
  end

  def start_date
    klass.start_date.to_s
  end

  def end_date
    klass.end_date.to_s
  end

  def job_start_date
    @hired_interaction.start_date.to_s if @hired_interaction
  end

  def hire_title
    @hired_interaction.hire_title if @hired_interaction
  end

  def hire_salary
    @hired_interaction.hire_salary if @hired_interaction
  end

  def employer_location
    hired_employer.location if hired_employer
  end

  def student_id
    trainee.trainee_id
  end
end
