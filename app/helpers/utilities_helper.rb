include ActionView::Helpers::NumberHelper
# for generic helper methods
module UtilitiesHelper
  def format_phone_no(phone_no, ext = nil)
    return nil unless phone_no
    phone = phone_no.delete('^0-9')
    phone = number_to_phone(phone, area_code: (phone.length > 9))
    phone += " x(#{ext})" unless ext.blank?
    phone
  end

  def opero_str_to_date(s_date, format = nil)
    return nil if s_date.blank?
    m, d, y = s_date.split('/') # making an assumption %m/%d/%Y.delete("^0-9")
    return nil unless m && d && y
    return nil unless Date.valid_date?(y.to_i, m.to_i, d.to_i)

    s_dt = s_date

    format ||= Date::DATE_FORMATS[:default]
    s_dt = build_mm_dd_yyyy(s_dt) if format == '%m/%d/%Y'

    DateTime.strptime(s_dt, format).to_date
  end

  # input is either mm/dd/yy or mm/dd/yyyy
  # output should be mm/dd/yyyy
  def build_mm_dd_yyyy(dt)
    dp = dt.split('/')
    return dt if dp[2].size == 4
    dt[2] = '20' + dt[2] if dt[2].size == 2
    dp.join('/')
  end

  def name_and_link(object, to_label = false)
    return object.name unless policy(object).show?
    link_to(to_label ? object.to_label : object.name, object)
  end

  def full_calendar_link(calendar)
    return nil if calendar.invalid_dates
    link_to(visits_calendar_klass_path(calendar.klass)) do
      "<i class = 'icon-calendar icon-2x green'></i>" \
      '<strong> Full Calendar</strong>'.html_safe
    end
  end
end
