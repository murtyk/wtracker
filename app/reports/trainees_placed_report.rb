# frozen_string_literal: true

# placement information about placed trainees
class TraineesPlacedReport < Report
  def post_initialize(params)
    return unless params && params[:action] != 'new'

    @trainee_interactions = trainee_placed_interactions

    t_ids = @trainee_interactions.pluck(:trainee_id)
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
    klass_ids = klasses.pluck :id
    t_ids = KlassTrainee.where(klass_id: klass_ids).pluck(:trainee_id)

    TraineeInteraction
      .includes(employer: :address)
      .includes(trainee: { klass_trainees: { klass: { college: :address } } })
      .where(termination_date: nil, trainee_id: t_ids)
      .order('trainees.first, trainees.middle, trainees.last')
  end

  def find_trainees_placed_no_employer(trainee_ids)
    KlassTrainee.includes(:trainee, klass: :college)
                .where(status: 4)
                .where(klass_id: klass_ids)
                .where.not(trainee_id: trainee_ids)
  end
end
