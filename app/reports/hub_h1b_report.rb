# for RTW grant reporting
class HubH1bReport < Report
  attr_accessor :funding_source_id
  attr_reader :trainees

  def post_initialize(params)
    initialize_objects
    return unless params && params[:action] != 'new'
    @funding_source_id = params[:funding_source_id]
    build_trainees
  end

  def initialize_objects
    @trainees = []
  end

  def start_date
    @start_date || quarter_start_date
  end

  def end_date
    @end_date || quarter_end_date
  end

  def build_excel
    excel_file = ExcelFile.new(user, 'hub_h1b')
    excel_file.add_row builder.header
    excel_file.add_row builder.header_numbers
    trainees.each do |trainee|
      row = builder.build_row(trainee)
      excel_file.add_row row
    end
    excel_file.save
    excel_file
  end

  def builder
    @builder ||= HubH1bViewBuilder.new
  end

  def th
    builder.th
  end

  def trs
    trainees[0..20].map { |t| builder.tr(t) }.join('').html_safe
  end

  # trainees with any of the following on or before end_date
  #   placed
  #   enrolled in OJT
  #   participated in a training class or workshop
  def build_trainees
    trainee_ids = placed_ids + in_a_klass_ids
    @trainees = Trainee.includes(:klasses,
                                 :trainee_interactions,
                                 :applicant,
                                 tact_three: :education)
                .where(id: trainee_ids,
                       funding_source_id: funding_source_id)
  end

  def placed_ids
    TraineeInteraction.where(status: [4, 6], termination_date: nil)
      .where('created_at >= ?', start_date)
      .where('created_at <= ?', end_date)
      .pluck(:trainee_id)
  end

  def in_a_klass_ids
    KlassTrainee.joins(:klass)
      .where('klasses.start_date >= ?', start_date)
      .where('klasses.start_date <= ?', end_date)
      .pluck(:trainee_id)
  end


  # Employed in 1st Quarter After Program Completion
  # Occupational Code
  # Entered Training-Related Employment
  # Retained Current Position
  # "Advanced into a New Position with Current Employer in the 1st Quarter after Completion"
  # Retained Current Position in the 2nd Quarter after Program Completion
  # "Advanced into a New Position with Current Employer in the 2nd Quarter after Program Completion"
  # Retained Current Position in the 3rd Quarter After Program Completion
  # "Advanced into a New Position with Current Employer in the 3rd Quarter after Program Completion"
  def data_500s(_t)
  end

  # Type of Recognized Credential #1
  # Date Attained Recognized Credential #1
  # Type of Recognized Credential #2
  # Date Attained Recognized Credential #3
  # Type of Recognized Credential #3
  # Date Attained Recognized Credential #3
  def data_600s(_t)
  end

  def title
    'Hub H1B Report'
  end

  def count
    @trainees.count
  end

  def template
    'hub_h1b'
  end

                      # JAN FEB MAR APR MAY JUN JULY AUG SEP OCT NOV DEC
  QUARTER_START_MONTH = [10, 10, 10, 1,  1,  1,  4,   4,  4,  7,  7,  7]
  def quarter_start_date
    m  = Date.current.month
    sm = QUARTER_START_MONTH[m-1]
    y  = Date.current.year
    y -= 1 if sm > m
    Date.new(y, sm, 1)
  end

  def quarter_end_date
    quarter_start_date + 3.months - 1.day
  end
end
