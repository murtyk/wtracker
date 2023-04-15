# frozen_string_literal: true

include UtilitiesHelper
# factory for create and update
class KlassEventFactory
  def self.create(ke_params, current_user)
    klass_event = build_event(ke_params)
    if klass_event.save
      UserMailer.send_event_invite(klass_event, current_user).deliver_now
    else
      klass_event.event_date = ke_params[:event_date]
    end
    klass_event
  end

  def self.build_event(ke_params)
    employer_ids = ke_params[:employer_ids]
    employer_ids.delete('')
    klass_event = KlassEvent.new(ke_params.except(:event_date, :employer_ids))

    klass_event.event_date = opero_str_to_date(ke_params[:event_date])
    employer_ids.each do |e_id|
      klass_event.klass_interactions.new(employer_id: e_id.to_i, status: 1)
    end
    klass_event
  end

  def self.update_klass_event(ke, ke_params, current_user)
    employer_ids = ke_params[:employer_ids]
    employer_ids.delete('')

    new_ids             = employer_ids.map(&:to_i)
    existing_ids        = ke.klass_interactions.pluck(:employer_id)
    delete_ids, add_ids = delete_and_add_ids(existing_ids, new_ids)

    update_event(ke, ke_params, current_user, add_ids, delete_ids)
    ke
  end

  def self.delete_and_add_ids(existing_employer_ids, new_employer_ids)
    delete_ids   = existing_employer_ids - new_employer_ids
    add_ids      = new_employer_ids - existing_employer_ids
    [delete_ids, add_ids]
  end

  def self.update_event(ke, ke_params, current_user, add_ids, del_ids)
    params = ke_params.except(:event_date, :employer_ids).clone
    params[:event_date] = opero_str_to_date(ke_params[:event_date])

    if ke.update(params)
      interactions_to_del = ke.klass_interactions.where(employer_id: del_ids)
      ke.klass_interactions.destroy(interactions_to_del)
      add_ids.each do |id|
        ke.klass_interactions.create(employer_id: id, status: 1)
      end
      UserMailer.send_event_invite(ke, current_user).deliver_now
    else
      ke.event_date = ke_params[:event_date]
    end
  end
end
