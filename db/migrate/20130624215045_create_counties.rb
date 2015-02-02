class CreateCounties < ActiveRecord::Migration
  def change
    create_table :counties do |t|
      t.references :state,  :null => false
      t.string :name,  :null => false

      t.timestamps
    end
    add_index :counties, :state_id
  end
end
