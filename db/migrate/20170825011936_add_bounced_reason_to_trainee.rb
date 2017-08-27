class AddBouncedReasonToTrainee < ActiveRecord::Migration
  def change
    add_column :trainees, :bounced_reason, :string
  end
end
