include UtilitiesHelper
# for doing CRUD on trainee interactions
class TraineeInteractionFactory
  # Builds new trainee interaction for ajax form.
  # Called from Trainee Page
  def self.build(params)
    trainee = Trainee.find(params[:trainee_id])
    ti = trainee.trainee_interactions.new
    check_open_placement(ti)
  end

  # creates a TI
  # Updates status of klass_trainees
  def self.create(all_params)
    params = all_params[:trainee_interaction].clone

    trainee = Trainee.find(params.delete(:trainee_id))

    start_date = opero_str_to_date(params['start_date'])
    params[:start_date] = start_date

    create_ti_and_update_statuses(trainee, params)

    trainee
  end

  # updates start date, title, salary and comments
  # not Employer ID
  def self.update(all_params)
    params = all_params[:trainee_interaction].clone

    trainee_interaction = TraineeInteraction.find(all_params[:id])

    params.delete(:trainee_id)

    trainee_interaction.start_date = opero_str_to_date(params.delete('start_date'))
    trainee_interaction.termination_date =
      opero_str_to_date(params.delete('termination_date'))
    trainee_interaction.update_attributes(params)

    change_klass_statuses(trainee_interaction)
    trainee_interaction
  end

  # Change KlassTrainee status to Completed when unhired
  def self.destroy(params)
    ti = TraineeInteraction.find(params[:id])
    klass_trainees = ti.trainee.klass_trainees
    ti.destroy
    # we do not use update_all since it does not update timestamp
    ti.trainee.update(status: 0) if ti.hired?
    klass_trainees.each { |kt| kt.update(status: 2) } if ti.hired?
    ti
  end

  def self.create_ti_and_update_statuses(trainee, params)
    params.delete(:klass_id)
    ti = trainee.trainee_interactions.new(params)
    check_already_placed(ti)
    return if ti.errors.any?
    return unless trainee.save
    change_klass_statuses(ti)
  end

  # create and update actions call this
  # ti status: terminated || hired || ojt enrolled
  def self.change_klass_statuses(ti)
    trainee = ti.trainee
    if ti.terminated? || ti.hired?
      status = ti.terminated? ? 2 : 4 # Completed or Placed
      kts = trainee.klass_trainees
    else # ti.ojt_enrolled?
      status = 2 # Completd.
      # change only the placed ones
      kts = trainee.klass_trainees.where(status: 4)
    end
    kts.each { |kt| kt.update(status: status) }
  end

  def self.check_already_placed(ti)
    trainee = ti.trainee
    if trainee && trainee.hired?
      error = 'Already Placed.'
      ti.errors.add(:base, error)
      trainee.errors.add(:base, error)
    end
    ti
  end

  def self.check_open_placement(ti)
    check_already_placed(ti)
    unless ti.errors.any?
      trainee = ti.trainee
      if trainee &&
         trainee.trainee_interactions
         .where(status: 5, termination_date: nil).count > 0
        error = 'Already OJT Enrolled'
        ti.errors.add(:base, error)
        trainee.errors.add(:base, error)
      end
    end
    ti
  end
end
