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
    KlassTrainee::STATUSES.keys.map do |status|
      klass_trainees = klass.klass_trainees_by_status(status)
      next if klass_trainees.empty?

      it = OpenStruct.new
      it.status_name   = "#{KlassTrainee::STATUSES[status]} - #{klass_trainees.count}"
      it.div_id = "klass_trainees_#{KlassTrainee::STATUSES[status]}"
      it.klass_trainees = klass_trainees
      it
    end.compact
  end

  def klass_events_group_by_type
    ['Class Visit', 'Site Visit', 'Information Session', 'Other'].map do |event_type|
      event_type_events = events_by_type(event_type)

      next unless event_type_events.any?

      data = accordion_fields(event_type, event_type_events.count)
      data.klass_events = event_type_events
      data
    end.compact
  end

  def accordion_fields(event_type, count)
    group_id = "accordion-group-#{event_type}s"
    href     = '#' + "#{event_type.gsub(' ', '_')}_events"
    heading  = "#{event_type.pluralize} (#{count})"
    body_id  = "#{event_type.gsub(' ', '_')}_events"

    OpenStruct.new(accordion_group_id: group_id,
                   accordion_href: href,
                   accordion_heading: heading,
                   accoridon_body_id: body_id)
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
