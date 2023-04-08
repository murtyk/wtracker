# frozen_string_literal: true

# only consider one class per trainee
class TraineeInteractionDetails < DelegateClass(TraineeInteraction)
  attr_reader :klasses

  def initialize(obj)
    super(obj)
    @klasses = trainee.klasses
  end

  def navigator
    return nil unless trainee.applicant

    trainee.applicant.navigator_name
  end
end
