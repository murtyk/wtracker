class AddParamsToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :params, :text
  end
end
