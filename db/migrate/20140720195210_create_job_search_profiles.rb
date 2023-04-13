# frozen_string_literal: true

class CreateJobSearchProfiles < ActiveRecord::Migration
  def change
    create_table :job_search_profiles do |t|
      t.references :account, index: true
      t.references :trainee, index: true
      t.text :skills
      t.string :location
      t.integer :distance
      t.string :key

      t.timestamps
    end
  end
end
