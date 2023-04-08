# frozen_string_literal: true

class CreateTraineeServices < ActiveRecord::Migration
  def change
    create_table :trainee_services do |t|
      t.date :start_date, null: false
      t.date :end_date
      t.string :name, null: false
      t.references :trainee
      t.references :account
      t.references :grant

      t.timestamps null: false
    end
    add_foreign_key :trainee_services, :trainees
    add_foreign_key :trainee_services, :accounts
    add_foreign_key :trainee_services, :grants

    add_index :trainee_services, %i[account_id grant_id trainee_id],
              name: :trainee_services_scope
  end
end
