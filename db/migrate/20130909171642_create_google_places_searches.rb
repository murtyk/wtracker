class CreateGooglePlacesSearches < ActiveRecord::Migration
  def change
    create_table :google_places_searches do |t|
      t.string :name
      t.references :city
      t.float :score
      t.references :opero_company

      t.timestamps
    end
    add_index :google_places_searches, [:name, :city_id]
    add_index :google_places_searches, :opero_company_id
  end
end
