# frozen_string_literal: true

class AddDateToTraineeAssessments < ActiveRecord::Migration
  def change
    add_column :trainee_assessments, :date, :date
  end
end
