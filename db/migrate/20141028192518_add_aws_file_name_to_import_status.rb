# frozen_string_literal: true

class AddAwsFileNameToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :aws_file_name, :text
  end
end
