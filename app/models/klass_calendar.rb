# for building class calendar to render a brief or full calendar
class KlassCalendar
  attr_accessor :first_monday, :last_monday, :event_counts,
                :klass, :all_types, :invalid_dates, :error
  def initialize(klass)
    @klass = klass
    if klass.start_date && klass.end_date
      @first_monday = klass.start_date.beginning_of_week
      @last_monday = klass.end_date.beginning_of_week
      @event_counts = @klass.klass_events.group(:event_date).count
    else
      @invalid_dates = true
      @error = 'invalid class start/end dates'
    end
  end

  def visit_type(event)
    return 0 if @invalid_dates
    return 1 if event.name.downcase.include?('site visit')
    return 2 if event.name.downcase.include?('class visit')
    0
  end

  def event_rows(event_date)
    return 0 if @invalid_dates
    next_day = event_date.beginning_of_week
    count = 1
    (0..5).each do |_d|
      date_event_count = @event_counts[next_day].to_i
      count = date_event_count if date_event_count > count
      next_day = next_day.tomorrow
    end
    count
  end

  def get_event(dt, row_no)
    return nil if @invalid_dates
    date_event_count = @event_counts[dt].to_i
    return nil if date_event_count < row_no
    events = @klass.klass_events.where('event_date = ?', dt).order(:id)
    events[row_no - 1]
  end

  def event_time(event)
    return 'All Day' unless event.start_time_hr.to_i > 0

    t = build_start_time_string(event)

    return t unless event.end_time_hr.to_i > 0

    t + '-' + build_end_time_string(event)
  end

  EVENT_COLORS = ['#ccf', '#FFD966', '#92D050']
  def event_color(event)
    EVENT_COLORS[visit_type(event)]
  end

  private

  def time_s(hr, min, ampm)
    format('%s:%02d%s', hr, min, ampm)
  end

  def build_start_time_string(event)
    time_s(event.start_time_hr.to_s, event.start_time_min.to_i, event.start_ampm)
  end

  def build_end_time_string(event)
    time_s(event.end_time_hr.to_s, event.end_time_min.to_i, event.end_ampm)
  end
end
