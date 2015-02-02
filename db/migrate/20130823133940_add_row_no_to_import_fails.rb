class AddRowNoToImportFails < ActiveRecord::Migration
  def change
    add_column :import_fails, :row_no, :integer
  end
end
