# frozen_string_literal: true

class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.references :account,  null: false
      t.string :name
      t.integer :administered_by

      t.timestamps
    end
    add_index :assessments, :account_id
  end
end
