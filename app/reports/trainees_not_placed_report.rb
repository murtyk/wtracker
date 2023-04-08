# frozen_string_literal: true

# data for trainees not placed report
class TraineesNotPlacedReport < Report
  def post_initialize(params)
    return unless params && params[:action] != 'new'

    build_not_placed_data
  end

  # find trainees with klass status Completed or Dropped
  def build_not_placed_data
    kts = KlassTrainee
          .includes(trainee: %i[funding_source trainee_notes],
                    klass: { college: :address })
          .where(klass_trainees: { status: [2, 3] })
          .where(klasses: { id: klass_ids })
          .order('trainees.first, trainees.last')
    @trainees_not_placed = kts.map { |kt| TraineeNotPlaced.new(kt) }
  end

  def trainees_not_placed
    @trainees_not_placed || []
  end

  def title
    'Trainees Dropped or Not Placed'
  end

  delegate :count, to: :trainees_not_placed
end
