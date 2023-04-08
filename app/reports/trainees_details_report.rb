# frozen_string_literal: true

include UtilitiesHelper
# contains data for trainee details report
# view renders trainees by class
class TraineesDetailsReport < Report
  attr_reader :count, :klasses_data

  def post_initialize(params)
    @klasses_data = []
    @count = 0
    return unless params && params[:action] != 'new'

    init_klasses
    init_placements_data if placements?
    init_klass_trainees_data
  end

  def title
    'Trainees Details'
  end

  # subclass can override this
  def placements?
    false
  end

  def placement_data(trainee)
    @placements_data[trainee.id]
  end

  def klasses_and_trainees
    @klasses_and_trainees || []
  end

  def init_klasses
    @klass_index = {}

    index = 0
    ordered_klasses.each do |klass|
      @klass_index[klass.id] = index

      @klasses_data << [klass, klass_link(klass), []]
      index += 1
    end
  end

  def init_klass_trainees_data
    klass_trainees.each do |klass_trainee|
      klass = klass_trainee.klass
      trainee = klass_trainee.trainee
      index = @klass_index[klass.id]
      @klasses_data[index][2] << trainee_data(trainee, klass_trainee.status_text)

      @count += 1
    end
  end

  def trainee_data(trainee, status)
    td = trainee_base_data(trainee, status)

    if placements?
      pd = placement_data(trainee)
      return td unless pd

      return td + (0..3).map { |i| pd.try('[]', i) }
    end

    td + [trainee.recent_employer,
          trainee.job_title,
          trainee.years,
          trainee.certifications]
  end

  def trainee_base_data(trainee, status)
    [
      trainee.id,
      trainee_link(trainee),
      trainee.funding_source_name,
      status,
      trainee.trainee_id,
      trainee.formatted_address,
      trainee.dob.to_s,
      trainee.gender.to_i == 1 ? 'M' : 'F',
      trainee.veteran ? 'x' : '',
      trainee.education_name,
      land_no(trainee),
      mobile_no(trainee),
      trainee.email
    ]
  end

  def land_no(trainee)
    format_phone_no(trainee.land_no)
  end

  def mobile_no(trainee)
    format_phone_no(trainee.mobile_no)
  end

  def init_placements_data
    @placements_data = {}
    tis = TraineeInteraction
          .includes(employer: :address)
          .where(status: [4, 5, 6], termination_date: nil)
    tis.each do |ti|
      @placements_data[ti.trainee_id] = [employer_link(ti.employer),
                                         ti.employer_location,
                                         ti.start_date,
                                         ti.hire_salary]
    end
  end

  def klass_trainees
    KlassTrainee
      .includes(:klass, trainee: [:home_address,
                                  :funding_source,
                                  { tact_three: :education }])
      .where(klass_id: klass_ids)
    # .order('trainees.first, trainees.middle, trainees.last')
  end

  def ordered_klasses
    order = 'colleges.name, klasses.start_date, klasses.end_date'
    klasses.order(order)
  end
end
