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
    KlassTrainee::STATUSES.map do |status, name|
      klass_trainees = klass_trainees_by_status(status)
      next if klass_trainees.empty?

      OpenStruct.new(status_name: "#{name} - #{klass_trainees.count}",
                     div_id: "klass_trainees_#{name}",
                     klass_trainees: klass_trainees)
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
    @kes ||= klass_events
             .includes(klass_interactions: :employer)
             .order('event_date desc').decorate

    et = event_type.downcase

    return @kes.select { |ke| ke.name.downcase == et } unless et == 'other'

    @kes.select { |ke| !NOT_OTHER_EVENTS.index(ke.name.downcase) }
  end

  def certificate_names
    klass_certificates.map(&:name).join('<br>').html_safe
  end

  # below are for dashboard
  # [1 => "Enrolled", 2 => "Completed",3 => "Dropped",
  #  4 => "Placed", 5 => "Continuing Education"]
  def trainees_status_counts
    status_counts = {}
    klass_trainees.select('count(*), status')
      .group(:status)
      .each { |kts| status_counts[kts.status] = kts.count.to_i }
    status_counts
  end

  def enrolled_count
    trainees.count # initially enrolled = total
  end

  def dropped_count
    trainees_status_counts[3].to_i
  end

  def completed_count
    # subtract dropped and still in enrolled status ones from total
    enrolled_count - trainees_status_counts[1].to_i - dropped_count
  end

  def continuing_education_count
    trainees_status_counts[5].to_i
  end

  def placed_count
    trainees_status_counts[4].to_i
  end

  def not_placed_count
    trainees_status_counts[2].to_i # still in completed status waiting for placement
  end

  def placement_rate
    # completed and placed together is our target for placement
    divisor = not_placed_count + placed_count + continuing_education_count
    divisor > 0 ? (dividend.to_f * 100 / divisor).round(0).to_s + '%' : ''
  end

  def dividend
    placed_count + continuing_education_count
  end

  def klass_trainees_sorted
    klass_trainees.includes(trainee: :trainee_notes)
      .order('klass_trainees.status, trainees.first, trainees.last')
      .references(:trainees)
  end

  def klass_trainees_by_status(status)
    klass_trainees.select { |kt| kt.status == status }
  end

  def calendar
    @calendar ||= KlassCalendar.new(self)
  end
end
