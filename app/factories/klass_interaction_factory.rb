include UtilitiesHelper
# for creation and update of interactions between
# a class and an employer
class KlassInteractionFactory
  # 2 ways we can come here
  # Case 1: From Employer Page - New Class Interaction
  #     a. Employer id should be present
  #     b. Existing Event or New Event
  #     c. If existing event, interaction might exist
  # Case 2: From New Emp Class Int Menu
  #     a. Employer is new (no employer_id)
  #     b. Event exists or new
  #     c. Interaction exists or new

  # create employer if new
  # create event and send emails if new event
  # update interaction if exists
  # create interaction if new
  def self.create_klass_interaction(params, current_user)
    employer, klass_event, new_event = find_or_build_objects(params.clone)
    status      = params[:klass_interaction][:status]
    saved       = save_objects(employer, klass_event, status)

    if saved && new_event
      UserMailer.send_event_invite(klass_event, current_user).deliver_now
    end

    klass_interaction = KlassInteraction.new(status: status)
    klass_interaction.employer = employer

    clean_up(params, employer, klass_event) unless saved

    [saved, klass_interaction, klass_event, employer]
  end

  def self.find_or_build_objects(params)
    employer    = find_or_build_employer(params)
    klass_event = find_or_build_event(params)
    new_event   = klass_event.new_record?
    [employer, klass_event, new_event]
  end

  def self.find_or_build_employer(params)
    employer_id = params[:klass_interaction][:employer_id]
    return Employer.find(employer_id) unless employer_id.blank?

    emp_params     = params[:employer]
    address_params = emp_params[:address_attributes]
    emp_params.delete(:address_attributes) if address_params[:city].blank?
    Employer.new(emp_params)
  end

  def self.find_or_build_event(params)
    if params[:klass_event][:name].blank?
      return KlassEvent.find(params[:klass_interaction][:klass_event_id])
    end
    klass_id  = params[:klass_interaction][:klass_id]
    ke_params = params[:klass_event]
    klass     = Klass.find(klass_id)
    ke_params[:event_date] = opero_str_to_date(ke_params[:event_date])
    klass.klass_events.build(ke_params)
  end

  def self.save_objects(employer, klass_event, status)
    begin
      ActiveRecord::Base.transaction do
        employer.save! if employer.new_record?
        klass_event.save! if klass_event.new_record?
        update_or_create_klass_interaction(klass_event, employer, status)
      end
    rescue
      return false
    end
    true
  end

  def self.update_or_create_klass_interaction(klass_event, employer, status)
    ki = klass_event.klass_interactions
                    .find_or_initialize_by(employer_id: employer.id)
    ki.status = status
    ki.save!
  end

  def self.clean_up(params, employer, klass_event)
    address_params = params[:employer][:address_attributes]
    employer.build_address(address_params) unless employer.address
    klass_event.event_date = params[:klass_event][:event_date]
  end

  def self.update_klass_interaction(all_params, current_user)
    klass_interaction = KlassInteraction.find(all_params[:id])
    params = all_params[:klass_interaction]
    params.delete(:employer_id)

    if params[:klass_event]
      # event data also might be changed
      klass_event = klass_interaction.klass_event
      update_event(klass_event, params[:klass_event], current_user)
      params.delete(:klass_event)
    end

    klass_interaction.update_attributes(params)
    klass_interaction
  end

  def self.update_event(klass_event, ke, current_user)
    event_date = opero_str_to_date(ke[:event_date])
    if event_chaged?(klass_event, ke, event_date)
      ke[:event_date] = event_date
      klass_event.update_attributes(ke)
      UserMailer.send_event_invite(klass_event, current_user).deliver_now
    end
  end

  def self.event_chaged?(klass_event, ke, event_date)
    f_same = klass_event.event_date  == event_date
    [:name, :notes, :start_ampm, :end_ampm].each do |attr|
      f_same &= (klass_event.send(attr.to_s) == ke[attr])
    end

    [:start_time_hr, :start_time_min,
     :end_time_hr, :end_time_min].each do |attr|
      f_same &= (klass_event.send(attr.to_s).to_i == ke[attr].to_i)
    end
    !f_same
  end
end
