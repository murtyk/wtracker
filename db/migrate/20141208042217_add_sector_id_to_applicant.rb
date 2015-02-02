class AddSectorIdToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :sector_id, :integer
  end
end
