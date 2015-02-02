class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :city, :null => false, :limit => 30
      t.string :county
      t.string :state, :null => false, :limit => 2
      t.string :zip, :null => false, :limit => 10
      t.string :country
      t.references :account,  :null => false
      t.integer :addressable_id
      t.string :addressable_type
      t.string :type
      t.float :latitude
      t.float :longitude
      t.boolean :gmaps

      t.timestamps
    end
    add_index :addresses, :account_id
    add_index :addresses, [:account_id, :addressable_id, :addressable_type], name: "addresses_index"
  end
end
