# hired trainee interactions tell us which employers hired
class EmployersHiredReport < Report
  def post_initialize(params)
    return unless params

    tis = trainee_interactions
    tis.sort! { |a, b| a.employer.name <=> b.employer.name }
    @hired_interactions = tis.map { |ti| TraineeInteractionDetails.new(ti) }
  end

  def hired_interactions
    @hired_interactions || []
  end

  def count
    hired_interactions.count
  end

  def trainee_interactions
    TraineeInteraction.joins(trainee: :klasses)
                      .includes(employer: :address)
                      .where(status: 4, klasses: { id: klass_ids }).to_a
  end
end
