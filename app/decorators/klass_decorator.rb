# decorator for klass
class KlassDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def trainees_by_status
    trainees = []
    KlassTrainee::STATUSES.keys.each do |status|
      klass_trainees = klass.klass_trainees_by_status(status)
      if klass_trainees.any?
        it = OpenStruct.new
        it.status_name   = "#{KlassTrainee::STATUSES[status]} - #{klass_trainees.count}"
        it.div_id = "klass_trainees_#{KlassTrainee::STATUSES[status]}"
        it.klass_trainees = klass_trainees
        trainees.push it
      end
    end
    trainees
  end

  def klass_events_group_by_type
    events = []
    ['Class Visit', 'Site Visit', 'Information Session', 'Other'].each do |event_type|
      event_type_events = events_by_type(event_type)
      if event_type_events.any?
        data = OpenStruct.new

        data.accordion_group_id = "accordion-group-#{event_type}s"
        data.accordian_href     = '#' + "#{event_type.gsub(' ', '_')}_events"
        data.accordion_heading  = "#{event_type.pluralize} (#{event_type_events.count})"
        data.accoridon_body_id  = "#{event_type.gsub(' ', '_')}_events"

        data.klass_events       = event_type_events

        events << data
      end
    end
    events
  end

  NOT_OTHER_EVENTS = ['class visit', 'site visit', 'information session']
  def events_by_type(event_type)
    if event_type.downcase == 'other'
      klass_events.where('LOWER(name) not in (?)', NOT_OTHER_EVENTS)
                  .order('event_date desc')
                  .decorate
    else
      klass_events.where('name ilike ?', event_type)
                  .order('event_date desc')
                  .decorate

    end
  end
end
