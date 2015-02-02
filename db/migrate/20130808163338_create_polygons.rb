class CreatePolygons < ActiveRecord::Migration
  def change
    create_table :polygons do |t|
      t.integer :mappable_id,  :null => false
      t.string :mappable_type,  :null => false
      t.text :json

      t.timestamps
    end
    add_index :polygons, [:mappable_id, :mappable_type]
  end
end


