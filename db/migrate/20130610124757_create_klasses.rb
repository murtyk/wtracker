# frozen_string_literal: true

class CreateKlasses < ActiveRecord::Migration
  def change
    create_table :klasses do |t|
      t.integer :college_id,    null: false
      t.string :name,           null: false
      t.string :description
      t.integer :training_hours
      t.integer :credits
      t.date :start_date
      t.date :end_date
      t.references :program,     null: false
      t.references :account,     null: false
      t.references :grant, null: false

      t.timestamps
    end
    add_index :klasses, %i[account_id grant_id program_id], name: 'klasses_index'
  end
end
