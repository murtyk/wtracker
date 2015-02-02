class AddLegalStatusToTrainee < ActiveRecord::Migration
  def change
    add_column :trainees, :legal_status, :integer
  end
end
