class FundingSourceMonthlyReport < Report
  attr_reader :funding_source_id, :ending_month

  def post_initialize(params)
    @funding_source_id = params[:funding_source_id]
    @ending_month = params[:ending_month]
  end

  def count
    funding_source_id ? 1 : 0
  end

  def has_data?
    funding_source_id
  end

  def header
    ["", "Monthly Avg.", "Year #{ending_month.to_date - 11.months} - #{ending_month.to_date}"]
  end

  def rows
    return [] unless funding_source_id

    data = [["Counseling Sessions (Workshops)", (workshops_in_year / 12.0).round(2), workshops_in_year]]
    assessments_in_year.each do |name, count|
      data << [name, (count / 12.0).round(2), count]
    end

    data << ["Participants in Training", (trainings_in_year / 12.0).round(2), trainings_in_year]
    data << ["Participants Completed Training", (trainings_completed_in_year / 12.0).round(2), trainings_completed_in_year]
    data << ["Participants Entered Employment", (placements_count / 12.0).round(2), placements_count]

    data
  end

  def funding_source
    funding_source_id && FundingSource.find(funding_source_id)
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

  def assessments_in_year
    start_time = ending_month.to_date.to_time - 11.months
    end_time = ending_month.to_date.to_time + 1.month

    assessment_counts = TraineeAssessment.
      joins(:assessment).
      where(trainee_id: trainee_ids).
      where("trainee_assessments.created_at >= ? and trainee_assessments.created_at < ?", start_time, end_time).
      group('assessments.name').
      count
  end

  def trainings_completed_in_year
    start_date = ending_month.to_date - 11.months
    end_date = ending_month.to_date + 1.month - 1.day

    KlassTrainee
      .joins(:klass)
      .where(status: [2,4,5])
      .where.not(klass_id: ws_klass_ids)
      .where("klasses.start_date >= ? and klasses.end_date <= ?", start_date, end_date)
      .count
  end

  def trainings_in_year
    start_date = ending_month.to_date - 11.months
    end_date = ending_month.to_date + 1.month - 1.day

    KlassTrainee
      .joins(:klass)
      .where.not(klass_id: ws_klass_ids)
      .where("klasses.start_date >= ? and klasses.end_date <= ?", start_date, end_date)
      .count
  end

  def workshops_in_year
    start_date = ending_month.to_date - 11.months
    end_date = ending_month.to_date + 1.month - 1.day

    KlassTrainee
      .joins(:klass)
      .where(klass_id: ws_klass_ids)
      .where("klasses.start_date >= ? and klasses.end_date <= ?", start_date, end_date)
      .count
  end

  def placements_count
    start_date = ending_month.to_date - 11.months
    end_date = ending_month.to_date + 1.month - 1.day

    trainee_ids = TraineeInteraction.
                    where(termination_date: nil).
                    where("start_date >= ? and start_date <= ?", start_date, end_date).
                    pluck(:trainee_id)

    (trainee_ids + placed_trainee_ids).uniq.count
  end

  def placed_trainee_ids
    start_date = ending_month.to_date - 11.months
    end_date = ending_month.to_date + 1.month - 1.day

    tps = TraineePlacement.where(trainee_id: trainee_ids)
    tps.select{|tp| tp.start_date >= start_date && tp.start_date <= end_date }.map(&:trainee_id)
  end

  def ws_klass_ids
    ws_klasses.select(:id)
  end

  def ws_klasses
    Klass.where(klass_category_id: ws_category_ids)
  end

  def ws_category_ids
    @ws_category_ids ||= KlassCategory.where(code: 'WS').pluck(:id)
  end

  def trainee_ids
    Trainee.where(funding_source_id: funding_source_id).select(:id)
  end

  def ending_months
    dt = Date.today
    12.times.map do
      dt -= 1.month
      dt.strftime("%b %Y").upcase
    end
  end
end
