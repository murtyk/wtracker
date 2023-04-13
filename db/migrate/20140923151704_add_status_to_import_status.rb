# frozen_string_literal: true

class AddStatusToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :status, :string
  end
end
