include UtilitiesHelper

class FundingSourceMonthlyReport < Report
  attr_reader :funding_source_id, :start_date, :ending_month, :skip_dates

  def post_initialize(params)
    @funding_source_id = params[:funding_source_id]
    @ending_month = params[:ending_month]
    @start_date = opero_str_to_date(params[:start_date])
    @skip_dates = false
  end

  def count
    funding_source_id ? 1 : 0
  end

  def has_data?
    funding_source_id
  end

  def header
    ["", "For #{ending_month}", "For #{start_date} - #{end_date}"]
  end

  def rows
    return [] unless funding_source_id

    data = [["Counseling Sessions (Workshops)", workshops_in_month, workshops_in_year]]
    data += assessment_period_counts

    data << ["Participants in Training", trainings_in_month, trainings_in_year]
    data << ["Participants Completed Training", trainings_completed_in_month, trainings_completed_in_year]
    data << ["Participants Entered Employment", placements_in_month_count, placements_in_year_count]

    data
  end

  def funding_source
    @funding_source ||= funding_source_id && FundingSource.find(funding_source_id)
  end

  def render_counts
    ""
  end

  def title
    "Funding Source Monthly Report"
  end

  def selection_partial
    'single_funding_source_selection'
  end

  def build_excel
    excel_file = ExcelFile.new(user, 'fs_monthly', "Details")

    excel_file.add_row data_header
    data_rows.each do |row|
      excel_file.add_row row
    end

    excel_file.add_sheet("Summary")

    excel_file.add_row header
    rows.each do |row|
      excel_file.add_row row
    end

    excel_file.add_sheet("No Dates Filter")

    @start_date = "01/01/2000".to_date
    @ending_month = "DEC 2030"
    @skip_dates = true

    excel_file.add_row data_header
    data_rows.each do |row|
      excel_file.add_row row
    end

    excel_file.save
    excel_file
  end

  def data_header
    ["TAPO ID", "Trainee", "Trainee ID", "Address", "Mobile", "email",
      "Job Developer", "Workshops", "Assessment Name", "Assessment Date",
      "Trainings", "Start Date", "End Date", "Training Hours",
      "Status", "Hired Company", "Title", "Start Date", "Salary",
      "Uses Traineed Skills",
      "UI Verfied Date", "UI Verified Notes", "Funding Source"].flatten
  end

  def data_rows
    rows = []
    all_trainees.map do |trainee|
      trainee_d = trainee.decorate
      trainings_of_trainee(trainee).map do |training_name, start_date, end_date, training_hours|
        rows << [trainee.id,
          trainee.name,
          trainee.trainee_id,
          trainee_d.home_address,
          trainee_d.mobile_no(true),
          trainee.email,
          trainee.navigator_name,
          workshops_of_trainee(trainee),
          assessments_of_trainee(trainee),
          training_name,
          start_date,
          end_date,
          training_hours,
          placement_status(trainee),
          placement_info(trainee),
          ui_verification_info(trainee),
          funding_source.name
          ].flatten
      end
    end
    rows
  end

  def workshops_of_trainee(trainee)
    klasses = trainee.
                klass_trainees.map(&:klass).
                select{ |k| k.klass_category_code == "WS" && k.start_date >= month_start_date && k.end_date <= end_date }
    klasses.map do |klass|
      "#{klass.name} - #{klass.start_date} - #{klass.end_date}"
    end.join(";")
  end

  def assessments_of_trainee(trainee)
    tas = trainee.trainee_assessments

    unless skip_dates
      tas = tas.where("date >= ? and date <= ?", month_start_date, end_date)
    end

    # assessment_names.map do |name|
    #   tas.select{|ta| ta.name == name}.map(&:date).map(&:to_s).flatten.join(";")
    # end

    ta = tas.all.sort{ |a,b| a.date <=> b.date }.first
    [ta.try(:name), ta.try(:date).to_s]
  end

  def trainings_of_trainee(trainee)
    klasses = trainee.
                klass_trainees.map(&:klass).
                select{ |k| k.klass_category_code != "WS" && k.start_date >= month_start_date && k.start_date <= end_date }
    trainings = klasses.map do |klass|
      [klass.name, klass.start_date, klass.end_date, klass.training_hours]
    end
    trainings.any? ? trainings : [["","","",""]]
  end

  def completions_of_trainee(trainee)
    klasses = trainee.
                klass_trainees.
                select{|kt| [2,4,5].include?(kt.status) }.
                map(&:klass).
                select{ |k| k.klass_category_code != "WS" && k.end_date >= month_start_date && k.end_date <= end_date }
    klasses.map do |klass|
      "#{klass.name} - #{klass.start_date} - #{klass.end_date}"
    end.join(";")
  end

  def placement_status(trainee)
    ti = trainee.
          trainee_interactions.find do |ti|
            ti.start_date &&
            ti.start_date >= month_start_date &&
            ti.start_date < end_date
          end

    return "" unless ti

    ti.termination_date.nil? ? "Placed" : "Terminated"
  end

  def placement_info(trainee)
    ti = trainee.
          trainee_interactions.find do |ti|
            ti.termination_date.nil? &&
            ti.start_date &&
            ti.start_date >= month_start_date &&
            ti.start_date < end_date
          end

    return [""] * 5 unless ti

    [ti.employer.name, ti.hire_title, ti.start_date, ti.hire_salary, ti.uses_trained_skills]
  end

  def ui_verification_info(trainee)
    [
      trainee.ui_claim_verified_on,
      trainee.ui_verified_notes.sort{|a,b| a.id <=> b.id}.last.try(:notes)
    ]
  end

  def all_trainees
    Trainee
      .where(id: all_trainee_ids)
      .includes(:ui_verified_notes,
                :funding_source,
                :home_address,
                klass_trainees: { klass: :klass_category },
                trainee_interactions: :employer,
                trainee_assessments: :assessment,
                applicant: :navigator)
      .order(:first, :last)
  end

  def all_trainee_ids
    [workshop_trainee_ids +
      assessment_trainee_ids +
      training_trainee_ids +
      completed_trainee_ids +
      placed_trainee_ids(month_start_date, end_date)].flatten.uniq
  end

  # ----for all_trainee_ids---------------------------
  def workshop_trainee_ids
    workshops(month_start_date, end_date).pluck(:trainee_id).uniq
  end

  def assessment_trainee_ids
    assessments(month_start_time, end_time).pluck(:trainee_id).uniq
  end

  def training_trainee_ids
    trainings(month_start_date, end_date).pluck(:trainee_id).uniq
  end

  def completed_trainee_ids
    trainings_completed(month_start_date).pluck(:trainee_id)
  end
  # --------------------------------------------------

  def assessments(st, et)
    tas = TraineeAssessment.
      joins(:assessment).
      where(trainee_id: trainee_ids)

    return tas if skip_dates

    tas.where("trainee_assessments.date >= ? and trainee_assessments.date < ?", st, et)
  end

  def assessment_counts(st, et)
    assessments(st, et).
      group('assessments.name').
      count
  end

  def assessment_month_counts
    assessment_counts(month_start_time, end_time)
  end

  def assessment_year_counts
    assessment_counts(start_time, end_time)
  end

  def assessment_period_counts
    year_counts = assessment_year_counts

    month_counts = assessment_month_counts

    asmt_names = (year_counts.keys + month_counts.keys).uniq.sort

    asmt_names.map do |name|
      [name, month_counts[name].to_i, year_counts[name].to_i]
    end
  end

  def assessment_names
    @assessment_names ||= Assessment.pluck(:name).sort
  end

  def trainings_completed(from_end_date)
    KlassTrainee
      .joins(:klass)
      .where(status: [2,4,5])
      .where.not(klass_id: ws_klass_ids)
      .where(trainee_id: trainee_ids)
      .where("klasses.end_date >= ? and klasses.end_date <= ?", from_end_date, end_date)
  end

  def trainings_completed_count(fed)
    trainings_completed(fed).count
  end

  def trainings_completed_in_month
    trainings_completed_count(month_start_date)
  end

  def trainings_completed_in_year
    trainings_completed_count(start_date)
  end

  def trainings(sd, ed)
    KlassTrainee
      .joins(:klass)
      .where.not(klass_id: ws_klass_ids)
      .where(trainee_id: trainee_ids)
      .where("klasses.start_date >= ? and klasses.start_date <= ?", sd, ed)
  end

  def trainings_count(sd, ed)
    trainings(sd, ed).count
  end

  def trainings_in_month
    trainings_count(month_start_date, end_date)
  end

  def trainings_in_year
    trainings_count(start_date, end_date)
  end

  def workshops(sd, ed)
    KlassTrainee
      .joins(:klass)
      .where(klass_id: ws_klass_ids)
      .where(trainee_id: trainee_ids)
      .where("klasses.start_date >= ? and klasses.end_date <= ?", sd, ed)
  end

  def workshops_count(sd, ed)
    workshops(sd, ed).count
  end

  def workshops_in_year
    workshops_count(start_date, end_date)
  end

  def workshops_in_month
    workshops_count(month_start_date, end_date)
  end

  def placements_count(sd, ed)
    placed_trainee_ids(sd, ed).count
  end

  def placements_in_month_count
    placements_count(month_start_date, end_date)
  end

  def placements_in_year_count
    placements_count(start_date, end_date)
  end

  def placed_trainee_ids(sd, ed)
    TraineeInteraction.
      where(trainee_id: trainee_ids).
      where(termination_date: nil).
      where("start_date >= ? and start_date <= ?", sd, ed).
      pluck(:trainee_id).
      uniq
  end

  def end_date
    @end_dt ||= ending_month.to_date + 1.month - 1.day
  end

  def start_time
    @st ||= start_date.to_time
  end

  def end_time
    @et ||= end_date.to_time + 1.day
  end

  def month_start_date
    return start_date if skip_dates
    @mst ||= ending_month.to_date
  end

  def month_start_time
    @met ||= month_start_date.to_time
  end

  def ws_klass_ids
    ws_klasses.select(:id)
  end

  def ws_klasses
    Klass.where(klass_category_id: ws_category_ids)
  end

  def ws_category_ids
    @ws_category_ids ||= KlassCategory.where(code: 'WS').select(:id)
  end

  def trainee_ids
    Trainee.where(funding_source_id: funding_source_id).select(:id)
  end

  def ending_months
    dt = Date.today
    6.times.map do
      dt -= 1.month
      dt.strftime("%b %Y").upcase
    end
  end

  def template
    "funding_source_monthly"
  end
end
