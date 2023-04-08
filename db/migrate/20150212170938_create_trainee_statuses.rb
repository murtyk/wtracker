# frozen_string_literal: true

class CreateTraineeStatuses < ActiveRecord::Migration
  def change
    create_table :trainee_statuses do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.references :grant_trainee_status, index: true
      t.references :trainee, index: true
      t.string :notes

      t.timestamps null: false
    end
    add_foreign_key :trainee_statuses, :accounts
    add_foreign_key :trainee_statuses, :grants
    add_foreign_key :trainee_statuses, :grant_trainee_statuses
    add_foreign_key :trainee_statuses, :trainees
  end
end
