include UtilitiesHelper
# factory for create and update
class KlassEventFactory
  def self.create(params, current_user)
    klass_event = build_event(params.clone)
    if klass_event.save
      UserMailer.send_event_invite(klass_event, current_user).deliver_now
    else
      klass_event.event_date = params[:klass_event][:event_date]
    end
    klass_event
  end

  def self.build_event(params)
    ke_params = params[:klass_event]
    employer_ids = ke_params.delete(:employer_ids)
    employer_ids.delete('')
    klass = Klass.find(params[:klass_id])
    klass_event = klass.klass_events.new(ke_params)

    klass_event.event_date = opero_str_to_date(ke_params[:event_date])
    employer_ids.each do |e_id|
      klass_event.klass_interactions.new(employer_id: e_id.to_i, status: 1)
    end
    klass_event
  end

  def self.update_klass_event(params, current_user)
    klass_event = KlassEvent.find(params[:id])
    params[:klass_event][:event_date] =
          opero_str_to_date(params[:klass_event][:event_date])
    employer_ids = params[:klass_event].delete(:employer_ids)
    employer_ids.delete('')

    new_ids             = employer_ids.map { |id| id.to_i }
    existing_ids        = klass_event.klass_interactions.pluck(:employer_id)
    delete_ids, add_ids = delete_and_add_ids(existing_ids, new_ids)

    update_event(params, current_user, klass_event, add_ids, delete_ids)
    klass_event
  end

  def self.delete_and_add_ids(existing_employer_ids, new_employer_ids)
    delete_ids   = existing_employer_ids - new_employer_ids
    add_ids      = new_employer_ids - existing_employer_ids
    [delete_ids, add_ids]
  end

  def self.update_event(params, current_user, ke, add_ids, del_ids)
    if ke.update_attributes(params[:klass_event])
      interactions_to_del = ke.klass_interactions.where(employer_id: del_ids)
      ke.klass_interactions.destroy(interactions_to_del)
      add_ids.each do |id|
        ke.klass_interactions.create(employer_id: id, status: 1)
      end
      UserMailer.send_event_invite(ke, current_user).deliver_now
    else
      ke.event_date = params[:klass_event][:event_date]
    end
  end
end
