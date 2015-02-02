class AddDataToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :data, :text
  end
end
