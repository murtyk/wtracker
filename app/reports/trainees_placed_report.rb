# placement information about placed trainees
class TraineesPlacedReport < Report
  def post_initialize(params)
    return unless params

    @trainee_interactions = trainee_placed_interactions

    t_ids = @trainee_interactions.map { |ti| ti.trainee_id }
    @trainee_interactions.to_a.sort! do |a, b|
      a.trainee.name <=> b.trainee.name
    end
    @trainees_placed_no_employer = find_trainees_placed_no_employer(t_ids)
  end

  def trainee_interactions
    @trainee_interactions || []
  end

  def trainees_placed_no_employer
    @trainees_placed_no_employer || []
  end

  def title
    'Trainees Got Placed'
  end

  def count
    trainee_interactions.count + trainees_placed_no_employer.count
  end

  def trainee_placed_interactions
    TraineeInteraction.joins(trainee: :klasses)
                      .includes(employer: :address)
                      .where(status: 4, klasses: { id: klass_ids })
  end

  def find_trainees_placed_no_employer(trainee_ids)
    KlassTrainee.includes(:trainee, klass: :college)
                .where(status: 4)
                .where(klass_id: klass_ids)
                .where.not(trainee_id: trainee_ids)
  end
end
