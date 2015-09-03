class AddCompletionDateToTraineeInteractions < ActiveRecord::Migration
  def change
    add_column :trainee_interactions, :completion_date, :date
  end
end
