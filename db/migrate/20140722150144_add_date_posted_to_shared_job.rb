# frozen_string_literal: true

class AddDatePostedToSharedJob < ActiveRecord::Migration
  def change
    add_column :shared_jobs, :date_posted, :datetime
  end
end
