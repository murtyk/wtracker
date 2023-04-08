# frozen_string_literal: true

class CreateSharedJobs < ActiveRecord::Migration
  def change
    create_table :shared_jobs do |t|
      t.string :title
      t.text :details_url
      t.text :excerpt
      t.references :job_share
      t.references :account

      t.timestamps
    end
    add_index :shared_jobs, :job_share_id
    add_index :shared_jobs, :account_id
  end
end
