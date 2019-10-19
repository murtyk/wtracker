# for each employer, show the classes where the employer is active
class ActiveEmployersReport < Report
  attr_reader :employers_klasses, :total_employers, :trainees_hired,
              :klass_trainee_ids, :employer_interactions

  delegate :count, to: :employers_klasses

  def post_initialize(params)
    initialize_objects
    return unless params && params[:action] != 'new'

    build_employers_klasses
    build_employer_interactions
    build_trainees_hired
    sort_employer_klasses
  end

  def title
    'Active Employers'
  end

  # called from view
  def trainees_hired_by_employer(employer_id, klass_id)
    trainees_hired.map do |th|
      th.trainee if th.employer_id == employer_id &&
                    klass_trainee_ids[klass_id].include?(th.trainee_id)
    end.compact
  end

  def render_employer_klass_interactions(klass, employer_id)
    employer_interactions.map do |ki|
      next unless ki.employer_id == employer_id && ki.for_klass?(klass)
      if ki.status == 4
        "<p style='color: red'>#{ki.event_date} #{ki.event_name}</p>"
      else
        "<p>#{ki.event_date}  #{ki.event_name}</p>"
      end
    end.compact.join.html_safe
  end

  def initialize_objects
    @employers_klasses = []
    @klass_trainee_ids = {}
  end

  def build_employers_klasses
    klasses.each do |klass|
      employers_ids = klass_employers_ids(klass)
      emps = Employer.includes(:contacts, :address).where(id: employers_ids).decorate

      emps.each { |e| @employers_klasses.push [e, klass] }

      @klass_trainee_ids[klass.id] = klass.trainees.pluck(:id)
    end
  end

  def build_employer_interactions
    @employer_interactions = KlassInteraction.includes(:klass_event).where(nil)
    @employer_interactions.first # load
  end

  def klass_employers_ids(klass)
    (employers_any_interest_ids(klass) +
        employers_hired_ids(klass)).uniq
  end

  def employers_any_interest_ids(klass)
    Employer.joins(klass_interactions: { klass_event: :klass })
      .where(klasses: { id: klass.id })
      .pluck('employers.id').uniq
  end

  def employers_hired_ids(klass)
    Employer.joins(trainee_interactions: { trainee: :klasses })
      .where(trainee_interactions: { status: [4, 6], termination_date: nil })
      .where(klasses: { id: klass.id })
      .pluck('employers.id').uniq
  end

  def build_trainees_hired
    @trainees_hired =
      TraineeInteraction.joins(trainee: :klasses)
      .select('trainee_interactions.employer_id, klasses.id as klass_id,
                                 trainee_interactions.trainee_id')
      .where(trainee_interactions: { status: [4, 6], termination_date: nil })
      .where(klasses: { id: klasses.map(&:id) })
    @trainees_hired.first
  end

  def sort_employer_klasses
    @employers_klasses.sort! { |a, b| a[0].name <=> b[0].name }
    @total_employers = @employers_klasses.map { |ek| ek[0] }.uniq.count
  end
end
