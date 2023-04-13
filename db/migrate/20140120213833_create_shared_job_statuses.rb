# frozen_string_literal: true

class CreateSharedJobStatuses < ActiveRecord::Migration
  def change
    create_table :shared_job_statuses do |t|
      t.references :account
      t.references :trainee
      t.references :shared_job
      t.integer :status
      t.string :feedback
      t.string :key

      t.timestamps
    end
    add_index :shared_job_statuses, :account_id
    add_index :shared_job_statuses, :trainee_id
    add_index :shared_job_statuses, :shared_job_id
  end
end
