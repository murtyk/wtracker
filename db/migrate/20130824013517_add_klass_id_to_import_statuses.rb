# frozen_string_literal: true

class AddKlassIdToImportStatuses < ActiveRecord::Migration
  def change
    add_column :import_statuses, :klass_id, :integer
  end
end
