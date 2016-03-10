class AddEmploymentStatusToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :employment_status, :string
  end
end
