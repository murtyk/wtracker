class CreateTraineeFiles < ActiveRecord::Migration
  def change
    create_table :trainee_files do |t|
      t.references :account,  :null => false
      t.references :trainee,  :null => false
      t.string :file
      t.string :notes
      t.integer :uploaded_by

      t.timestamps
    end
    add_index :trainee_files, [:account_id, :trainee_id]
  end
end
