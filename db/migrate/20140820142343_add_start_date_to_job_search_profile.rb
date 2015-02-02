class AddStartDateToJobSearchProfile < ActiveRecord::Migration
  def change
    add_column :job_search_profiles, :start_date, :date
  end
end
