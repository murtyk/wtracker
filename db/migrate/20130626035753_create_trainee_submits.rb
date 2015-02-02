class CreateTraineeSubmits < ActiveRecord::Migration
  def change
    create_table :trainee_submits do |t|
      t.references :account,  :null => false
      t.references :trainee,  :null => false
      t.references :employer,  :null => false
      t.string :title

      t.timestamps
    end
    add_index :trainee_submits, [:account_id, :trainee_id]
    add_index :trainee_submits, [:account_id, :employer_id]
  end
end
