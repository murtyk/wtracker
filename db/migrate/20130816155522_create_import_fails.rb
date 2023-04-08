# frozen_string_literal: true

class CreateImportFails < ActiveRecord::Migration
  def change
    create_table :import_fails do |t|
      t.references :account
      t.references :import_status
      t.text :row_data
      t.string :error_message
      t.boolean :can_retry
      t.boolean :geocoder_fail

      t.timestamps
    end
    add_index :import_fails, :account_id
    add_index :import_fails, :import_status_id
  end
end
