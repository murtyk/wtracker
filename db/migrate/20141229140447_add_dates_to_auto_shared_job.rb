# frozen_string_literal: true

class AddDatesToAutoSharedJob < ActiveRecord::Migration
  def change
    add_column :auto_shared_jobs, :notes_updated_at, :date
    add_column :auto_shared_jobs, :status_updated_at, :date
  end
end
