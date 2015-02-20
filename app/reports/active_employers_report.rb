# for each employer, show the classes where the employer is active
class ActiveEmployersReport < Report
  attr_reader :total_employers, :trainees_hired,
              :klass_trainee_ids, :employer_interactions
  def post_initialize(params)
    @employers_klasses = []
    return unless params

    init_employers_klasses

    @employer_interactions = KlassInteraction.includes(:klass_event).where(nil)
    init_trainees_hired
    # debugger
    @employer_interactions.first
    @trainees_hired.first
    @employers_klasses.sort! { |a, b| a[0].name <=> b[0].name }
    @total_employers = @employers_klasses.map { |ek| ek[0] }.uniq.count
  end

  def title
    'Active Employers'
  end

  def count
    employers_klasses.count
  end

  def employers_klasses
    @employers_klasses || []
  end

  def init_employers_klasses
    @klass_trainee_ids = {}
    klasses.each do |klass|
      employers_ids = (employers_any_interest_ids(klass) +
                       employers_hired_ids(klass)).uniq
      emps = Employer.includes(:contacts, :address).where(id: employers_ids).decorate

      emps.each { |e| @employers_klasses.push [e, klass] }

      @klass_trainee_ids[klass.id] = klass.trainees.pluck(:id)
    end
  end

  def employers_any_interest_ids(klass)
    Employer.joins(klass_interactions: { klass_event: :klass })
            .where(klasses: { id: klass.id })
            .pluck('employers.id').uniq
  end

  def employers_hired_ids(klass)
    Employer.joins(trainee_interactions: { trainee: :klasses })
            .where(trainee_interactions: { status: 4 })
            .where(klasses: { id: klass.id })
            .pluck('employers.id').uniq
  end

  def init_trainees_hired
    @trainees_hired =
      TraineeInteraction.joins(trainee: :klasses)
                        .select('employer_id, klasses.id as klass_id,
                                 trainee_interactions.trainee_id')
                        .where(trainee_interactions: { status: 4 })
                        .where(klasses: { id: klasses.map { |k| k.id } })
  end
end
