# frozen_string_literal: true

class DefaultValuesInKlassSchedules < ActiveRecord::Migration
  def change
    change_column_default(:klass_schedules, :scheduled, false)
    change_column_default(:klass_schedules, :start_ampm, 'am')
    change_column_default(:klass_schedules, :start_time_hr, 0)
    change_column_default(:klass_schedules, :start_time_min, 0)
    change_column_default(:klass_schedules, :end_ampm, 'pm')
    change_column_default(:klass_schedules, :end_time_hr, 0)
    change_column_default(:klass_schedules, :end_time_min, 0)
  end
end
