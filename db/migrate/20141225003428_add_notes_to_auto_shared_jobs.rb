class AddNotesToAutoSharedJobs < ActiveRecord::Migration
  def change
    add_column :auto_shared_jobs, :notes, :text
  end
end
