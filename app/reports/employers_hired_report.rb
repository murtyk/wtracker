# hired trainee interactions tell us which employers hired
class EmployersHiredReport < Report
  attr_accessor :all_trainees

  def post_initialize(params)
    return unless params

    @all_trainees = params[:all_trainees].to_i == 1
    tis = trainee_interactions
    tis.sort! { |a, b| a.employer.name <=> b.employer.name }
    @hired_interactions = tis.map { |ti| TraineeInteractionDetails.new(ti) }
  end

  def hired_interactions
    @hired_interactions || []
  end
  delegate :count, to: :hired_interactions

  def title
    'Employers Hired'
  end

  def selection_partial
    'employers_hired_selection'
  end

  def trainee_interactions
    if all_trainees
      return TraineeInteraction.joins(:trainee)
        .includes(employer: :address)
        .where(status: 4).to_a
    end
    TraineeInteraction.joins(trainee: :klasses)
      .includes(employer: :address)
      .where(status: 4, klasses: { id: klass_ids }).to_a
  end
end
