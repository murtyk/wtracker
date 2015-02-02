class StatusDefaultKlassTrainees < ActiveRecord::Migration
  def change
  	change_column_default(:klass_trainees, :status, 1)
  end
end
