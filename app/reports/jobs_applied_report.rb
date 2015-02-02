# trainees applied for jobs
class JobsAppliedReport < Report
  def post_initialize(params)
    return unless params
    trainee_ids = TraineeSubmit.joins(trainee: :klasses)
                               .select('trainee_submits.trainee_id')
                               .where(klasses: { id: klass_ids }).uniq

    @trainees = Trainee.includes(:trainee_submits).where(id: trainee_ids)
  end

  def trainees
    @trainees || []
  end

  def count
    trainees.count
  end
end
