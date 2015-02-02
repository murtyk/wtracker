# only consider one class per trainee
class TraineeInteractionDetails < DelegateClass(TraineeInteraction)
  attr_reader :klass
  def initialize(obj)
    super(obj)
    @klass = trainee.klasses.first
  end

  def klass_name
    @klass.name if @klass
  end

  def college_name_location
    @klass.college_name_location if @klass
  end
end
