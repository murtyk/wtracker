require 'icalendar'
include ActionView::Helpers::NumberHelper
include UtilitiesHelper
# builds ical and other email parts for klass event
class EventMailBuilder
  attr_accessor :klass_event, :to_emails, :from_email, :subject, :ical_event, :ical
  def initialize(ke, user, f_cancel)
    @klass_event = ke
    @user = user
    @cancel = f_cancel
  end

  def build
    build_to_emails
    build_from_email
    build_ical_event

    build_ical

    build_email_subject
  end

  def build_email_subject
    # debugger
    suffix = @ical_event.sequence > 0 ? ' - UPDATE' : ' - NEW'
    suffix = ' - CANCELLED' if klass_event.destroyed?
    @subject = klass_event.name + suffix
  end

  def build_ical
    @ical = Icalendar::Calendar.new
    @ical.ip_method = @cancel ? 'CANCEL' : 'REQUEST'

    @ical.add_event(@ical_event)
  end

  def build_to_emails
    # need to confirm the recepients
    @to_emails = User.where(role: 2).pluck(:email).join(';')
    include_navigator_emails
    include_instructor_emails

    @to_emails = User.where(role: 1).first.email if to_emails.blank?
  end

  def include_navigator_emails
    return unless klass_event.klass.navigators.any?
    @to_emails += ';' + klass_event.klass.navigators
                        .pluck(:email)
                        .join(';')
  end

  def include_instructor_emails
    return unless klass_event.klass.instructors.any?
    @to_emails += ';' + klass_event.klass
                        .instructors
                        .pluck(:email)
                        .join(';')
  end

  def build_from_email
    @from_email = "#{@user.name}<#{@user.email}>" if @user
    @from_email ||= "Support<#{ENV['SUPPORT_FROM_EMAIL']}>"
  end

  def build_ical_event
    @ical_event = Icalendar::Event.new

    assign_ical_event_start_end_dates
    assign_ical_event_description

    @ical_event.summary   = klass_event.name
    @ical_event.organizer = ENV['DO_NOT_REPLY_EMAIL']
    @ical_event.klass     = 'PRIVATE'
    @ical_event.uid       = klass_event.uid
    @ical_event.sequence  = klass_event.sequence
  end

  private

  def assign_ical_event_start_end_dates
    unless klass_event.start_time_hr.to_i > 0
      assign_start_end_dates
      return
    end

    @ical_event.dtstart = format_start_date_time

    return unless klass_event.end_time_hr.to_i > 0

    @ical_event.dtend = format_end_date_time
  end

  def assign_start_end_dates
    @ical_event.dtstart = klass_event.event_date
    @ical_event.dtend   = klass_event.event_date
  end

  def format_start_date_time
    format_date_time(klass_event.event_date,
                     klass_event.start_time_hr,
                     klass_event.start_time_min,
                     klass_event.start_ampm)
  end

  def format_end_date_time
    format_date_time(klass_event.event_date,
                     klass_event.end_time_hr,
                     klass_event.end_time_min,
                     klass_event.end_ampm)
  end

  def assign_ical_event_description
    @ical_event.description = klass_event.klass_name + ' - ' +
      klass_event.name + ' - ' +
      klass_event.notes.to_s

    return unless visit_event?

    add_employer_details_to_description
  end

  def visit_event?
    klass_event.name.downcase.include?('visit')
  end

  def add_employer_details_to_description
    employer = klass_event.employers.first
    return unless employer

    @ical_event.description   += ' - ' + employer.name
    @ical_event.description   += ' - ' + format_phone_no(employer.phone_no)
    @ical_event.description   += ' - ' + employer.formatted_address
  end

  def format_date_time(dt, hr, m, ampm)
    hr += 12 if ampm == 'pm'
    hour = ('00' + hr.to_s)[-2..-1]
    minutes = ('00' + m.to_s)[-2..-1]
    dt.strftime('%Y%m%d') + 'T' + hour + minutes + '00'
  end
end
