# frozen_string_literal: true

class CreateColleges < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
      t.string :name
      t.references :account, null: false

      t.timestamps
    end
    add_index :colleges, :account_id
  end
end
