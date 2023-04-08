# frozen_string_literal: true

# schedule of a class
# class may be there only on some week days
class KlassSchedule < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  belongs_to :klass

  validates :start_time_hr,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 12 },
            allow_nil: true
  validates :start_time_min,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 59 },
            allow_nil: true
  validates :end_time_hr,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 12 },
            allow_nil: true
  validates :end_time_min,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 59 },
            allow_nil: true

  def day_name
    Date::DAYNAMES[dayoftheweek]
  end

  def start_time
    "#{start_time_hr}:#{start_time_min.to_s.rjust(2, '0')} #{start_ampm}"
  end

  def end_time
    "#{end_time_hr}:#{end_time_min.to_s.rjust(2, '0')} #{end_ampm}"
  end
end
