# trainees applied for jobs
class JobsAppliedReport < Report
  attr_reader :applied_data
  def post_initialize(params)
    return unless params && params[:action] != 'new'
    trainee_ids = TraineeSubmit.joins(trainee: :klasses)
                  .where(klasses: { id: klass_ids })
                  .pluck(:trainee_id).uniq

    @trainees = Trainee.includes(:trainee_submits).where(id: trainee_ids)
    build_data
  end

  def trainees
    @trainees || []
  end

  delegate :count, to: :trainees

  def title
    'Trainees Applied For Jobs'
  end

  def render_applied_dates(trainee)
    @applied_data[trainee.id][:applied_dates].html_safe
  end

  def render_applied_titles(trainee)
    @applied_data[trainee.id][:titles].html_safe
  end

  def applied_employers(trainee)
    @applied_data[trainee.id][:employers]
  end

  def build_data
    @applied_data = {}
    trainees.each { |trainee| build_trainee_data(trainee) }
  end

  def build_trainee_data(trainee)
    applied_dates = ''
    titles = ''
    employers = []
    trainee.trainee_submits.each do |job_applied|
      applied_dates += "<p>#{job_applied.applied_on}</p>"
      employers << job_applied.employer
      titles += "<p>#{job_applied.title}</p>"
    end
    @applied_data[trainee.id] = { applied_dates: applied_dates,
                                  employers: employers,
                                  titles: titles
                                }
  end
end
