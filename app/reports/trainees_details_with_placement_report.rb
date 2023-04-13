# frozen_string_literal: true

# details and placement information.
class TraineesDetailsWithPlacementReport < TraineesDetailsReport
  def title
    'Trainees Details With Placement Information'
  end

  def placements?
    true
  end
end
