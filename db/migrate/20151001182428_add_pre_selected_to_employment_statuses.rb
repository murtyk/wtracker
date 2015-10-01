class AddPreSelectedToEmploymentStatuses < ActiveRecord::Migration
  def change
    add_column :employment_statuses, :pre_selected, :boolean
  end
end
