# frozen_string_literal: true

class CreateEmployerNotes < ActiveRecord::Migration
  def change
    create_table :employer_notes do |t|
      t.references :employer, null: false
      t.references :account, null: false
      t.string :note, null: false

      t.timestamps
    end
    add_index :employer_notes, %i[account_id employer_id]
  end
end
