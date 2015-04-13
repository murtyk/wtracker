include UtilitiesHelper
# serves several factory methods
# 1. update klass trainee
#    additional scenarios - new emp interactions or update emp interaction
# 2. Add trainee to a class from klass page
# 3. Add class to a trainee from trainee page
# 4. Add multiple trainees through near by colleges page
class KlassTraineeFactory
  def self.update_klass_trainee(all_params)
    # debugger
    klass_trainee, trainee, f_status, status = init_objects(all_params)
    params = all_params[:klass_trainee].clone

    e_i = init_employer_interaction(status, trainee, params)
    params = clear_ei_attrs_from_params(params)
    updated, updated_eis = update(klass_trainee, params, f_status, status, e_i)

    trainee_page = all_params[:klass_trainee].delete(:trainee_id)

    build_decorator(klass_trainee, trainee_page, updated, updated_eis)
  end

  def self.build_decorator(kt, tp, up, up_eis)
    kt_d              = kt.decorate
    kt_d.trainee_page = tp
    kt_d.updated      = up
    kt_d.updated_eis  = up_eis
    kt_d
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
    assign_ei_attributes(ei, params)
    ei
  end

  def self.assign_ei_attributes(ei, params)
    title = params[:hire_title]
    ei.start_date  = opero_str_to_date(params[:start_date])
    ei.hire_title  = title.blank? ? 'missing' : title
    ei.hire_salary = params[:hire_salary]
    ei.comment     = params[:comment]
    ei.status      = params[:ti_status]
  end

  def self.clear_ei_attrs_from_params(params)
    [:hire_title, :hire_salary, :start_date, :comment,
     :employer_id, :employer_name, :ti_status].each { |k| params.delete(k) }
    params
  end

  def self.update(klass_trainee, params, f_status, status, e_i)
    updated_eis = !e_i.nil?
    begin
      klass_trainee.update_attributes(params)
      e_i.save if e_i
      was_hired = TraineeInteraction::STATUSES[f_status] == 'Hired'
      if (f_status != status) && was_hired
        klass_trainee.trainee.unhire
        updated_eis = true
      end
    rescue StandardError => error
      klass_trainee.errors.add(:base, error)
      return [false, updated_eis]
    end
    [true, updated_eis]
  end

  def self.new(params)
    return new_from_near_by_colleges(params) if params[:trainee_ids]

    if params[:trainee_id]
      trainee = Trainee.find params[:trainee_id]
      return [trainee.klass_trainees.build]
    end

    klass = Klass.find(params[:klass_id])
    [klass.klass_trainees.build]
  end

  def self.new_from_near_by_colleges(params)
    [
      nil,
      Trainee.where(id: params[:trainee_ids].split(',')),
      open_klasses
    ]
  end

  def self.open_klasses
    klasses  = Klass.where('start_date > ?', Date.today).order(:start_date)
    klasses.map do |k|
      [k.to_label + '-' + k.start_date.to_s + " (#{k.trainees.count})", k.id]
    end
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

    return add_klass_to_a_trainee(params) if params[:trainee_id] &&
                                             (params[:trainee_id].is_a? String)

    add_trainees_to_a_klass(params)
  end

  def self.add_klass_to_a_trainee(params)
    object = Trainee.find params[:trainee_id]
    object.klass_trainees.new(klass_id: params[:klass_id])
    object.save
    object
  end

  def self.add_trainees_to_a_klass(params)
    object = Klass.find(params[:klass_id])
    trainee_ids = params[:trainee_id] || params[:trainee_ids]
    trainee_ids = trainee_ids.split(',') if trainee_ids.is_a? String
    trainee_ids.delete('')
    trainee_ids.each { |id| object.klass_trainees.new(trainee_id: id) }
    object.save
    object
  end
end
