class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.references :state,  :null => false
      t.string :state_code,  :null => false
      t.string :zip
      t.string :city_state,  :null => false
      t.references :county,  :null => false
      t.string :name,  :null => false
      t.float :longitude,  :null => false
      t.float :latitude,  :null => false

      t.timestamps
    end
    add_index :cities, :state_id
    add_index :cities, :city_state
  end
end
