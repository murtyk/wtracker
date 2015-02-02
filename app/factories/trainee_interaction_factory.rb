include UtilitiesHelper
# for creating and updating trainee interactions
class TraineeInteractionFactory
  def self.build(params)
    trainee_page = !params[:trainee_id].blank?
    if trainee_page
      object = Trainee.find(params[:trainee_id])
    else
      object = Employer.find(params[:employer_id])
    end
    [trainee_page, object.trainee_interactions.new]
  end

  def self.create(params)
    employer_id = params[:trainee_interaction][:employer_id]
    comment = params[:trainee_interaction][:comment]

    # KORADA we get trainee_ids from employer page
    trainee_ids = params[:trainee_interaction][:trainee_ids]

    # we get trainee_id from trainee page
    trainee_id = params[:trainee_interaction][:trainee_id]

    if trainee_ids.nil? # trainee page
      object = Trainee.find(trainee_id)
      object.trainee_interactions.new(comment: comment,
                                      employer_id: employer_id, status: 1)
    else
      trainee_ids.delete('')
      object = Employer.find(employer_id)
      trainee_ids.each do |t_id|
        object.trainee_interactions.new(comment: comment, trainee_id: t_id, status: 1)
      end
    end
    object.save

    object
  end

  def self.update(params_all)
    params = params_all[:trainee_interaction].clone
    trainee_interaction = TraineeInteraction.find(params_all[:id])

    trainee_page = params.delete(:employer_id).nil?
    params.delete(:trainee_id)

    [:interview_date, :offer_date, :start_date].each do |attr|
      trainee_interaction.send("#{attr}=", opero_str_to_date(params.delete(attr)))
    end
    trainee_interaction.update_attributes(params)
    object = trainee_page ? trainee_interaction.trainee : trainee_interaction.employer
    [object, trainee_interaction]
  end

  def self.trainee_list_for_selection(params)
    klass_id = params[:klass_id]
    employer_id = params[:employer_id]

    trainee_ids = Employer.find(employer_id).trainee_interactions.map(&:trainee_id)
    trainee_ids.delete(nil)

    trainees = Klass.find(klass_id).trainees.where.not(id: trainee_ids)

    # trainees = trainees.where.not(id: trainee_ids) if trainee_ids.any?

    trainees.map { |trainee| { id: trainee.id, name: trainee.name } }
  end
end
