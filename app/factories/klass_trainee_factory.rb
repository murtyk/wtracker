include UtilitiesHelper
# update klass trainee:
class KlassTraineeFactory
  def self.update_klass_trainee(all_params)
    # debugger
    klass_trainee, trainee, f_status, status = init_objects(all_params)
    params = all_params[:klass_trainee].clone
    e_i = init_employer_interaction(status, trainee, params)
    [:hire_title, :hire_salary, :start_date,
     :employer_id, :employer_name].each { |k| params.delete(k) }
    updated, update_eis = update(klass_trainee, params, f_status, status, e_i)
    klass_trainee = klass_trainee.decorate
    klass_trainee.trainee_page = all_params[:klass_trainee].delete(:trainee_id)
    klass_trainee.updated = updated
    klass_trainee.update_employer_interactions = update_eis
    klass_trainee
  end

  def self.init_objects(params)
    klass_trainee = KlassTrainee.find(params[:id])
    trainee       = klass_trainee.trainee
    from_status   = klass_trainee.status
    status        = params[:klass_trainee][:status].to_i
    [klass_trainee, trainee, from_status, status]
  end

  def self.init_employer_interaction(status, trainee, params)
    id = params[:employer_id].to_i
    return nil unless status == 4 && id > 0
    ei = trainee.trainee_interactions.find_or_initialize_by(employer_id: id)
    title = params[:hire_title]
    ei.start_date = opero_str_to_date(params[:start_date])
    ei.hire_title = title.blank? ? 'missing' : title
    ei.hire_salary = params[:hire_salary]
    ei.status = 4
    ei
  end

  def self.update(klass_trainee, params, f_status, status, e_i)
    update_eis = e_i
    begin
      klass_trainee.update_attributes(params)
      e_i.save if e_i
      was_hired = TraineeInteraction::STATUSES[from_status] == 'Hired'
      if (f_status != status) && was_hired
        klass_trainee.trainee.unhire
        update_eis = true
      end
    rescue
      return [false, update_eis]
    end
    [true, update_eis]
  end

  # 3 ways to come here
  # Trainee Page:   params will have :trainee_id
  #        @object should be Trainee
  # Klass Page: params will have trainee_ids as array
  #        @object should be Klass
  # Near By Colleges ->  new.html -> trainee_ids as string
  #        @object should be Klass
  def self.add_klass_trainees(all_params)
    params = all_params[:klass_trainee]
    if params[:trainee_id] && (params[:trainee_id].is_a? String)
      object = Trainee.find params[:trainee_id]
      object.klass_trainees.new(klass_id: params[:klass_id])
    else
      object = Klass.find(params[:klass_id])
      trainee_ids = params[:trainee_id] || params[:trainee_ids]
      trainee_ids = trainee_ids.split(',') if trainee_ids.is_a? String
      trainee_ids.delete('')
      trainee_ids.each{ |id| object.klass_trainees.new(trainee_id: id) }
    end
    object.save
    object
  end
end
