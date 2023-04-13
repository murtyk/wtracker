# frozen_string_literal: true

class DropManualStatusTables < ActiveRecord::Migration
  def change
    remove_column :trainees, :gts_id
    drop_table :trainee_statuses
    drop_table :grant_trainee_statuses
  end
end
