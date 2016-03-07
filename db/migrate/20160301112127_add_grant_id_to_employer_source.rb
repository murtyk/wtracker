class AddGrantIdToEmployerSource < ActiveRecord::Migration
  def change
    add_column :employer_sources, :grant_id, :integer
  end
end
