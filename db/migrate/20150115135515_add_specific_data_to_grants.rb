class AddSpecificDataToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :specific_data, :hstore
  end
end
