# contains data for trainee details report
# view renders trainees by class
class TraineesDetailsReport < Report
  attr_reader :count
  def post_initialize(params)
    @count = 0
    return unless params
    init_klasses_and_trainees
  end

  def title
    'Trainees Details'
  end

  def klasses_and_trainees
    @klasses_and_trainees || []
  end

  def init_klasses_and_trainees
    @klasses_and_trainees = []
    klasses.each do |klass|
      trainees = klass.trainees.includes(:home_address, :tact_three)
      next if trainees.empty?
      trainees_details = trainees.map { |t| TraineeDetails.new(t) }
      @klasses_and_trainees.push [klass, trainees_details]
      @count += trainees.count
    end
  end
end
