class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.string :name,         :null => false
      t.date :start_date,     :null => false
      t.date :end_date,       :null => false
      t.integer :status,      :null => false
      t.integer :spots
      t.integer :amount
      t.references :account,  :null => false

      t.timestamps
    end
    add_index :grants, :account_id

  end
end
