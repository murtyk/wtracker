# frozen_string_literal: true

class CreateTraineeAssessments < ActiveRecord::Migration
  def change
    create_table :trainee_assessments do |t|
      t.references :account,  null: false
      t.references :trainee,  null: false
      t.references :assessment, null: false
      t.string :score
      t.boolean :pass

      t.timestamps
    end
    add_index :trainee_assessments, %i[account_id trainee_id]
  end
end
