# frozen_string_literal: true

# trainees status report show hired details for placed trainees
class TraineesStatusReport < Report
  attr_accessor :trainee_statuses

  def post_initialize(_params)
    @trainee_statuses = []
    return if klasses.blank?

    kts = klass_trainees
    trainee_ids = kts.map(&:trainee_id)
    init_placements_data(trainee_ids)
    build_trainee_statuses
  end

  def title
    'Trainees Status'
  end

  def count
    trainee_statuses.count
  end

  def build_trainee_statuses
    @trainee_statuses = klass_trainees.each.map { |kt| build_trainee_row(kt) }
  end

  def build_trainee_basic_data(kt)
    klass = kt.klass
    trainee = kt.trainee
    [
      trainee_link(trainee),
      trainee.trainee_id,
      klass_link(klass),
      trainee.funding_source_name,
      klass.start_date.to_s,
      klass.end_date.to_s,
      klass.college_name_location,
      notes(trainee),
      kt.status_text
    ]
  end

  def build_trainee_row(kt)
    trainee = kt.trainee
    build_trainee_basic_data(kt) + placement_data(trainee)
  end

  def klass_trainees
    KlassTrainee
      .includes({ klass: { college: :address } },
                trainee: %i[trainee_interactions trainee_notes])
      .where(klasses: { id: klass_ids })
      .order('trainees.first, trainees.last')
  end

  def placement_data(trainee)
    @placements_data[trainee.id] || ([''] * 5)
  end

  def init_placements_data(trainee_ids)
    @placements_data = {}
    tis = TraineeInteraction
          .includes(employer: :address)
          .where(termination_date: nil)
          .where(trainee_id: trainee_ids)
    tis.each do |ti|
      @placements_data[ti.trainee_id] = [employer_link(ti.employer),
                                         ti.employer_location,
                                         ti.hire_title,
                                         ti.start_date,
                                         ti.hire_salary]
    end
  end

  def klass_link(k)
    href = "/klasses/#{k.id}"
    name_link(href, k.name)
  end
end
