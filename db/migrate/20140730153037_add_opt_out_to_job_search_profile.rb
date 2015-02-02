class AddOptOutToJobSearchProfile < ActiveRecord::Migration
  def change
    add_column :job_search_profiles, :opted_out, :boolean
    add_column :job_search_profiles, :opt_out_reason, :string
    add_column :job_search_profiles, :company_name, :string
    add_column :job_search_profiles, :title, :string
    add_column :job_search_profiles, :salary, :string
  end
end
