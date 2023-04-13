# frozen_string_literal: true

class CreateFundingSources < ActiveRecord::Migration
  def change
    create_table :funding_sources do |t|
      t.references :account
      t.string :name

      t.timestamps
    end
    add_index :funding_sources, :account_id
  end
end
