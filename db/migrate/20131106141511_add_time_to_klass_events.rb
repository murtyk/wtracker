class AddTimeToKlassEvents < ActiveRecord::Migration
  def change
    add_column :klass_events, :start_ampm, :string
    add_column :klass_events, :start_time_hr, :integer
    add_column :klass_events, :start_time_min, :integer
    add_column :klass_events, :end_ampm, :string
    add_column :klass_events, :end_time_hr, :integer
    add_column :klass_events, :end_time_min, :integer
  end
end
