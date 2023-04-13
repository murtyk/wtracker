# frozen_string_literal: true

class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :code,  null: false
      t.string :name,  null: false

      t.timestamps
    end
    add_index :states, :code, unique: true
  end
end
