class CreateEmployerSectors < ActiveRecord::Migration
  def change
    create_table :employer_sectors do |t|
      t.references :account,  :null => false
      t.references :employer,  :null => false
      t.references :sector,  :null => false

      t.timestamps
    end
    add_index :employer_sectors, [:account_id, :employer_id]
    add_index :employer_sectors, [:account_id, :sector_id]
  end
end
