# frozen_string_literal: true

# trainee with activities in a date range
# with a particular status or all
class TraineesActivityReport < Report
  attr_reader :status, :trainee_activities

  def post_initialize(params)
    unless params && params[:action] != 'new'
      @status = nil
      @trainee_activities = []
      return
    end

    @status = params[:status].to_i

    trainees = build_trainees
    @trainee_activities = trainees.map do |trainee|
      TraineeActivity.new(trainee, filter_start_date, filter_end_date)
    end
  end

  def title
    'Trainees Activities'
  end

  def selection_partial
    'trainees_activity_selection'
  end

  delegate :count, to: :trainee_activities

  private

  def filter_start_date
    include_all_dates ? nil : start_date
  end

  def filter_end_date
    include_all_dates ? nil : end_date
  end

  def build_trainees
    ts = Trainee.joins(:klass_trainees)
                .preload(:klasses, :trainee_notes, :trainee_interactions)
                .order(:first, :last)
    ts = ts.where(klass_trainees: { klass_id: klass_ids })
    ts = ts.where('klass_trainees.status = ?', status) if status.positive?
    ts.uniq
  end
end
