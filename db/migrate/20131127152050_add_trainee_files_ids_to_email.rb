# frozen_string_literal: true

class AddTraineeFilesIdsToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :trainee_file_ids, :text
  end
end
