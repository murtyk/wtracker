class CreateOperoCompanies < ActiveRecord::Migration
  def change
    create_table :opero_companies do |t|
      t.string :name
      t.string :phone
      t.string :source
      t.string :line1
      t.string :city
      t.string :state_code
      t.references :state
      t.references :county
      t.string :zip
      t.string :formatted_address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    add_index :opero_companies, :state_id
    add_index :opero_companies, :county_id
  end
end
