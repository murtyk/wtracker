# about employers interested in trainees that are not placed yet
class EmployersInterestedReport < Report
  def post_initialize(params)
    return unless params
    tis = trainee_interactions
    tis.to_a.sort! { |a, b| a.employer_name <=> b.employer_name }
    @interactions = tis.map { |ti| TraineeInteractionDetails.new(ti) }
  end

  def title
    'Employers Interested in Trainees Not Placed'
  end

  def count
    interested_interactions.count
  end

  def interested_interactions
    @interactions || []
  end

  def placed_trainee_ids
    KlassTrainee.where(status: 4, klass_id: klass_ids).pluck(:trainee_id).uniq
  end

  def trainee_interactions
    tis = TraineeInteraction.joins(trainee: :klasses)
                            .includes(employer: :address)
                            .where(klasses: { id: klass_ids })

    return tis if placed_trainee_ids.blank?

    tis.where.not(trainee_interactions: { trainee_id: placed_trainee_ids })
  end
end
