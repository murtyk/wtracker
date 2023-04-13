# frozen_string_literal: true

class CreateTraineeAutoLeadStatuses < ActiveRecord::Migration
  def change
    create_table :trainee_auto_lead_statuses do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.references :trainee, index: true
      t.boolean :viewed
      t.boolean :applied

      t.timestamps null: false
    end
    add_foreign_key :trainee_auto_lead_statuses, :accounts
    add_foreign_key :trainee_auto_lead_statuses, :grants
    add_foreign_key :trainee_auto_lead_statuses, :trainees
  end
end
