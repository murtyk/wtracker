class CreateProgramInterests < ActiveRecord::Migration
  def change
    create_table :program_interests do |t|
      t.references :account,  :null => false
      t.references :program,  :null => false
      t.references :employer,  :null => false
      t.integer :interest

      t.timestamps
    end
    add_index :program_interests, [:account_id, :program_id]
  end
end
