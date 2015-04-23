# trainees status report show hired details for placed trainees
class TraineesStatusReport < Report
  def post_initialize(_params)
    return if klasses.blank?

    klass_trainees = klass_trainees_placed + klass_trainees_not_placed
    klass_trainees.to_a.sort! { |a, b| a.trainee.name <=> b.trainee.name }
    @trainee_statuses = klass_trainees.map { |kt| KlassTraineeStatus.new(kt) }
  end

  def trainee_statuses
    @trainee_statuses || []
  end

  def title
    'Trainees Status'
  end

  delegate :count, to: :trainee_statuses

  def klass_trainees_placed
    KlassTrainee.joins(:klass, trainee: :trainee_interactions)
      .where(klasses: { id: klass_ids })
      .where(trainee_interactions: { status: [4, 6], termination_date: nil })
  end

  def klass_trainees_not_placed
    KlassTrainee.includes(:trainee, :klass)
      .where.not(klass_trainees: { status: 4 })
      .where(klasses: { id: klass_ids })
      .references(:klasses)
  end
end
