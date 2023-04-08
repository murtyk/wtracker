# frozen_string_literal: true

class AddTerminationDateToTraineeInteractions < ActiveRecord::Migration
  def change
    add_column :trainee_interactions, :termination_date, :date
  end
end
