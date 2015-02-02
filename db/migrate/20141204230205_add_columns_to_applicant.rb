class AddColumnsToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :county_id, :integer
    add_column :applicants, :legal_status, :integer
    add_column :applicants, :veteran, :boolean
    add_column :applicants, :last_employer_name, :string
    add_column :applicants, :last_employer_city, :string
    add_column :applicants, :last_employer_state, :string
  end
end
