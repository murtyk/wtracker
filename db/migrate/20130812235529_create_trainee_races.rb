class CreateTraineeRaces < ActiveRecord::Migration
  def change
    create_table :trainee_races do |t|
      t.references :account,  :null => false
      t.references :trainee,  :null => false
      t.references :race,  :null => false

      t.timestamps
    end
    add_index :trainee_races, :account_id
  end
end
