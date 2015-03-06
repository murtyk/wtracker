# trainees applied for jobs
class JobsAppliedReport < Report
  def post_initialize(params)
    return unless params
    trainee_ids = TraineeSubmit.joins(trainee: :klasses)
                  .where(klasses: { id: klass_ids })
                  .pluck(:trainee_id).uniq

    @trainees = Trainee.includes(:trainee_submits).where(id: trainee_ids)
  end

  def trainees
    @trainees || []
  end

  delegate :count, to: :trainees

  def title
    'Trainees Applied For Jobs'
  end
end
