# hired trainee interactions tell us which employers hired
class EmployersHiredReport < Report
  attr_accessor :all_trainees, :status

  def post_initialize(params)
    return unless params && params[:action] != 'new'

    @all_trainees = params[:all_trainees].to_i == 1
    @status = params[:status].to_i
    build_hired_transactions
  end

  def build_hired_transactions
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
    status_ids = 5 if status == 5
    status_ids = [4, 5, 6] if status == 1
    status_ids ||= [4, 6]
    if all_trainees

      ti_ids = TraineeInteraction.joins(:trainee)
        .includes(employer: :address)
        .where(status: status_ids).pluck(:id)
    else
      ti_ids = TraineeInteraction.joins(trainee: :klasses)
        .includes(employer: :address)
        .where(status: status_ids, klasses: { id: klass_ids }).pluck(:id)
    end

    TraineeInteraction
      .includes(trainee: [{klasses: :college}, {applicant: :navigator}, :funding_source])
      .includes(employer: :address)
      .where(id: ti_ids).to_a
  end

  def status_collection
    [['Hired', 4], ['OJT Enrolled', 5], ['Hired Or OJT Entrolled', 1]]
  end
end
