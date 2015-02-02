# decorator for employer
# mainly used in show action
class EmployerDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def website_link
    return nil unless website?
    h.link_to(website, class: 'btn btn-flat btn-mini btn-info',
                       rel: 'tooltip', title: 'Visit Website', target: '_blank') do
      '<i class="icon-external-link white"></i>'.html_safe
    end
  end

  def phone_no
    return nil unless policy.show_contacts?
    "Main Phone No:#{h.format_phone_no(object.phone_no)}"
  end

  def policy
    @policy ||= EmployerPolicy.new(h.current_user, self)
  end

  def source_with_label
    return nil unless policy.show_source?
    '<b>Source:</b>'.html_safe + object.source
  end

  def source
    return nil unless policy.show_source?
    object.source
  end

  def created_date
    return nil unless policy.show_source?
    "<b>Create Date:</b>#{object.created_at.to_date}".html_safe
  end

  def address_details(skip_label = false)
    return nil unless policy.show_address?
    return '<b>Address not provided</b><br>'.html_safe unless object.address

    fa = [line1, city, "#{state} #{zip}", "county: <b>#{county_name}</b>"]
    fa.insert(0, '<b>Address:</b>') unless skip_label
    fa.join('<br>').html_safe
  end

  def contacts_header
    return unless policy.show_contacts?
    "<h4>
    Contacts
    #{h.button_new_association(Contact, contactable_id: id,
                                        contactable_type: Employer,
                                        title: 'New Contact')
    }
    </h4>".html_safe
  end

  def contacts
    return [] unless policy.show_contacts?
    object.contacts.decorate
  end

  def sectors
    sorted_employer_sectors
  end

  def trainee_interactions_header
    return nil unless TraineeInteractionPolicy.new(h.current_user).index?
    html = '<h4>' \
           'Short Listed Trainees ' +
           h.button_new_association(TraineeInteraction, employer_id: id) +
          '</h4>'
    html.html_safe
  end

  def trainee_submits_header
    return nil unless policy.show_trainee_submits?
    '<h4>Trainees Applied For Jobs</h4>'.html_safe
  end

  def trainee_submits
    return [] unless policy.show_trainee_submits?
    object.trainee_submits
  end

  def job_openings_header
    return unless policy.show_job_openings?
    "<h4>
    Job Openings
    #{h.button_new_association(JobOpening, employer_id: employer.id)}
    </h4>".html_safe
  end

  def job_openings
    return [] unless policy.show_job_openings?
    object.job_openings
  end

  def notes_header
    return unless policy.show_notes?
    btn_class = 'btn btn-flat btn-small btn-primary pull-right'
    "<h4>
    Notes
    #{h.button_new_association(EmployerNote,
                               employer_id: employer.id,
                               title: 'New Note')}
    <button type = 'button' id = 'employers_more_info_show' class = '#{btn_class}'>
    Show More
    </button>
    </h4>".html_safe
  end

  def employer_notes
    return [] unless policy.show_notes?
    object.employer_notes
  end

  def klass_interactions_header
    return unless policy.show_klass_interactions?
    "<h4>
    Class Interactions
    #{ h.plus_button(KlassInteraction,
                     { employer_id: employer.id },
                     'New Interaction with a Class') }
    </h4>".html_safe
  end

  def klasses
    object.klasses.order('start_date desc')
  end

  def klass_events(klass)
    kes = object.klass_events.where(klass_id: klass.id).decorate
    kes.each { |ke| ke.klass_interaction = klass_event_interaction(ke) }
    kes
  end

  def klass_event_interaction(klass_event)
    klass_interactions.where(klass_event_id: klass_event.id).first.decorate
  end

  def county_state
    "#{county} - #{state}"
  end
end
