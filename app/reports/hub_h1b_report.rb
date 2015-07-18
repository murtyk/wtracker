# for RTW grant reporting
class HubH1bReport < Report
  attr_reader :trainees

  def post_initialize(params)
    initialize_objects
    return unless params && params[:action] != 'new'
    build_trainees
  end

  def initialize_objects
    @trainees = []
  end

  def build_excel
    excel_file = ExcelFile.new(user, 'hub_h1b')
    excel_file.add_row builder.header
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

  # trainees with any of the following on or before before_date
  #   placed
  #   enrolled in OJT
  #   participated in a training class or workshop
  def build_trainees
    trainee_ids = placed_ids + in_a_klass_ids
    @trainees = Trainee.includes(:klasses,
                                 :trainee_interactions,
                                 :applicant,
                                 tact_three: :education)
                .where(id: trainee_ids)
  end

  def placed_ids
    TraineeInteraction.where(status: [4, 6], termination_date: nil)
      .where('created_at <= ?', before_date)
      .pluck(:trainee_id)
  end

  def in_a_klass_ids
    KlassTrainee.joins(:klass)
      .where('klasses.start_date <= ?', before_date)
      .pluck(:trainee_id)
  end

  # Date of Program Participation - Applicant Registered date
  # Date of Exit
  # Other Reasons for Exit (at time of exit or during 3-quarter measurement period following the quarter of exit)
  # Date of Program Completion
  # Most Recent Date Received Case Management Service
  # Previous Quarter Received Case Management Service
  # Most Recent Date Received Assessment Services
  # Previous Quarter Received Assessment Services
  # Most Recent Date Received Supportive Services
  # Previous Quarter Received Supportive Services
  # Most Recent Date Received Specialized Participant Services
  # Previous Quarter Received Specialized Services
  # Most Recent Date Participated in Work Experience
  # Previous Quarter Participated in Work Experience
  def data_300s(t)
    [f_date(t.applicant.created_at), exit_date(t), '', program_completion_date(t),
     klass_end_date(t), '', '', '', '', 0, '', 0,
     recent_ojt_enrolled_date(t), prev_ojt_enrolled_date(t)]
  end

  # Date Entered/Began Receiving Education/Job Training Activities #1
  # Occupational Skills Training Code  #1
  # Type of Training Service #1 - Primary
  # Type of Training Service #1 - Secondary
  # Type of Training Service #1 - Tertiary
  # Date Completed, or Withdrew from, Training #1
  # Training Completed #1
  # Date Entered/Began Receiving Education/Job Training Activities #2
  # Occupational Skills Training Code  #2
  # Type of Training Service #2 - Primary
  # Type of Training Service #2 - Secondary
  # Type of Training Service #2 - Tertiary
  # Date Completed, or Withdrew from, Training #2
  # Training Completed #2
  # Date Entered/Began Receiving Education/Job Training Activities #3
  # Occupational Skills Training Code  #3
  # Type of Training Service #3 - Primary
  # Type of Training Service #3 - Secondary
  # Type of Training Service #3 - Tertiary
  # Date Completed, or Withdrew from, Training #3
  # Training Completed #3
  def data_400s(t)
    [klass_or_ojt_start_date(t), '', klass_or_ojt?(t), klass_or_ojt?(t), klass_or_ojt?(t),
     klass_or_ojt_end_date(t), klass_or_ojt_end_date(t)]
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

  def before_date
    end_date
  end

  def exit_date(_t)
  end

  def program_completion_date(_t)
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
end
