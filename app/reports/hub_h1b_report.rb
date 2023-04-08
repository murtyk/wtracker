# frozen_string_literal: true

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

  # rubocop:disable Metrics/AbcSize
  def build_excel
    errors = []

    excel_file = ExcelFile.new(user, 'hub_h1b')
    excel_file.add_row builder.header
    excel_file.add_row builder.header_numbers
    trainees.each do |trainee|
      row = builder.build_row(trainee)
      excel_file.add_row row
    rescue StandardError => e
      errors << "trainee_id: #{trainee.id} #{e.message}"
    end

    AdminMailer.notify_hub_report_errors(errors).deliver_later if errors.any?

    excel_file.save([[2, :trainee_id]])
    excel_file
  end

  def builder
    @builder ||= HubH1bViewBuilder.new(start_date, end_date)
  end

  def th
    builder.th
  end

  def trs
    trainees[0..20].map { |t| builder.tr(t) }.join('').html_safe
  end

  def build_trainees
    @trainees = Trainee.includes(:trainee_interactions,
                                 :trainee_assessments,
                                 :applicant,
                                 klass_trainees: :klass,
                                 tact_three: :education)
                       .where(funding_source_id: funding_source_id)
                       .where('applicants.applied_on <= ?', end_date)
                       .references(:applicants)
  end

  # def placed_ids
  #   TraineeInteraction.where(status: [4, 5, 6], termination_date: nil)
  #     .where('start_date >= ?', start_date)
  #     .where('start_date <= ?', end_date)
  #     .pluck(:trainee_id)
  # end

  # def in_a_klass_ids
  #   KlassTrainee.joins(:klass)
  #     .where('klasses.start_date >= ?', start_date)
  #     .where('klasses.start_date <= ?', end_date)
  #     .pluck(:trainee_id)
  # end

  # def assessed_ids
  #   TraineeAssessment.where('date >= ?', start_date)
  #     .where('date <= ?', end_date)
  #     .pluck(:trainee_id)
  # end

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
  QUARTER_START_MONTH = [10, 10, 10, 1, 1, 1, 4, 4, 4, 7, 7, 7].freeze
  def quarter_start_date
    m  = Date.current.month
    sm = QUARTER_START_MONTH[m - 1]
    y  = Date.current.year
    y -= 1 if sm > m
    Date.new(y, sm, 1)
  end

  def quarter_end_date
    quarter_start_date + 3.months - 1.day
  end
end
