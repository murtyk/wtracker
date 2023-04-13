# frozen_string_literal: true

class AddZipToJobSearchProfile < ActiveRecord::Migration
  def change
    add_column :job_search_profiles, :zip, :string
  end
end
