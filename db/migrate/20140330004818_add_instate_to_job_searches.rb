class AddInstateToJobSearches < ActiveRecord::Migration
  def change
    add_column :job_searches, :in_state, :boolean
  end
end
