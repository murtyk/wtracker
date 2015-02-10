class AddRaceIdToTrainee < ActiveRecord::Migration
  def change
    add_column :trainees, :race_id, :integer
  end
end
