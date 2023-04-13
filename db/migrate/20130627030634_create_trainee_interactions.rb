# frozen_string_literal: true

class CreateTraineeInteractions < ActiveRecord::Migration
  def change
    create_table :trainee_interactions do |t|
      t.references :account, null: false
      t.references :grant, null: false
      t.references :employer, null: false
      t.references :trainee, null: false

      t.integer :status
      t.date :interview_date
      t.string :interviewer
      t.string :hire_title
      t.string :hire_salary

      t.date :offer_date
      t.date :start_date
      t.string :offer_title
      t.string :offer_salary
      t.text :comment

      t.timestamps
    end
    add_index :trainee_interactions, %i[account_id grant_id employer_id],
              name: 'trainee_interactions_employer_id_index'
    add_index :trainee_interactions, %i[account_id grant_id trainee_id],
              name: 'trainee_interactions_trainee_id_index'
  end
end
