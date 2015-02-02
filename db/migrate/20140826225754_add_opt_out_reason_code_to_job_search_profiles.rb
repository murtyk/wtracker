class AddOptOutReasonCodeToJobSearchProfiles < ActiveRecord::Migration
  def change
    add_column :job_search_profiles, :opt_out_reason_code, :integer
  end
end
