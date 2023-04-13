# frozen_string_literal: true

class CreateEmployerSources < ActiveRecord::Migration
  def change
    create_table :employer_sources do |t|
      t.string :name,        null: false
      t.references :account, null: false, index: true

      t.timestamps null: false
    end
    add_foreign_key :employer_sources, :accounts
  end
end
