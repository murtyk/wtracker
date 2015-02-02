class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name,         :null => false
      t.string :description,  :null => false
      t.integer :hours
      t.references :sector,   :null => false
      t.references :grant,    :null => false
      t.references :account,  :null => false

      t.timestamps
    end
    add_index :programs, [:account_id, :grant_id]
  end
end
