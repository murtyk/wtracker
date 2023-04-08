# frozen_string_literal: true

include UtilitiesHelper
# serves several factory methods
# 1. Update klass trainee
#    From Class Page only.
#    If status changed to Placed, new trainee interaction should be created
#    If TI status is No OJT or OJT Completed,
#       then all KTs should be updated with status placed
# 2. Adding a new KlassTrainee
#    1. From klass page
#    2. From trainee page
#    3. Add multiple trainees through near by colleges page
class KlassTraineeFactory
  def self.update_klass_trainee(id, kt_params)
    klass_trainee = KlassTrainee.find(id)
    params = extract_kt_params(kt_params)

    trainee = klass_trainee.trainee

    t_i = init_trainee_interaction(trainee, params)
    params = clear_ti_attrs_from_params(params)

    updated = update(klass_trainee, params, t_i)

    klass_trainee.reload if updated
    build_decorator(klass_trainee, t_i)
  end

  def self.build_decorator(kt, ti)
    kt_d = kt.decorate
    kt_d.trainee_interaction = ti
    kt_d
  end

  def self.extract_kt_params(kt_params)
    params = kt_params.clone
    status = params[:status].to_i
    # KT status will be changed to Placed by TI update
    params.delete(:status) if status == 4
    params
  end

  def self.init_trainee_interaction(trainee, params)
    id = params[:employer_id].to_i
    return nil unless id.positive?

    ti = trainee.trainee_interactions.find_or_initialize_by(employer_id: id)
    assign_ti_attributes(ti, params)
    ti
  end

  def self.assign_ti_attributes(ei, params)
    title = params[:hire_title]
    ei.start_date = opero_str_to_date(params[:start_date])
    ei.completion_date = opero_str_to_date(params[:completion_date])
    ei.hire_title  = title.blank? ? 'missing' : title
    ei.hire_salary = params[:hire_salary]
    ei.comment     = params[:comment]
    ei.status      = params[:ti_status]
    ei.uses_trained_skills = params[:uses_trained_skills]
  end

  def self.clear_ti_attrs_from_params(params)
    params.except(:hire_title, :hire_salary, :start_date, :completion_date,
                  :comment, :employer_id, :employer_name, :ti_status)
  end

  def self.update(klass_trainee, params, t_i)
    klass_trainee.update_attributes(params)
    if t_i
      saved = t_i.save
      update_klass_trainees_to_placed(t_i.trainee) if saved && t_i.placed?
    end
    true
  rescue StandardError => e
    klass_trainee.errors.add(:base, e)
    false
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
    klasses = Klass.where('start_date > ?', Date.today).order(:start_date)
    klasses.map do |k|
      ["#{k.to_label}-#{k.start_date} (#{k.trainees.count})", k.id]
    end
  end

  # 3 ways to come here
  # Trainee Page:   params will have :trainee_id
  #        @object should be Trainee
  # Klass Page: params will have trainee_ids as array
  #        @object should be Klass
  # Near By Colleges ->  new.html -> trainee_ids as string
  #        @object should be Klass
  def self.add_klass_trainees(params)
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
    trainee_ids.each do |id|
      trainee = Trainee.find id
      status = trainee.not_placed? ? 1 : 4
      object.klass_trainees.new(trainee_id: id, status: status)
    end
    object.save
    object
  end

  def self.update_klass_trainees_to_placed(trainee)
    trainee.klass_trainees.each { |kt| kt.update(status: 4) }
  end
end
