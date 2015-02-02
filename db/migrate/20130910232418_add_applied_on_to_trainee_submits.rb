class AddAppliedOnToTraineeSubmits < ActiveRecord::Migration
  def change
    add_column :trainee_submits, :applied_on, :date
  end
end
