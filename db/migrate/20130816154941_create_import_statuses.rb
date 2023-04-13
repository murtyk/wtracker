# frozen_string_literal: true

class CreateImportStatuses < ActiveRecord::Migration
  def change
    create_table :import_statuses do |t|
      t.references :account
      t.references :user
      t.string :file_name
      t.string :type
      t.integer :rows_successful
      t.integer :rows_failed
      t.string :sector_ids

      t.timestamps
    end
    add_index :import_statuses, :account_id
  end
end
