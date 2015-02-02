class CreateTactThrees < ActiveRecord::Migration
  def change
    create_table :tact_threes do |t|
      t.references :account,  :null => false
      t.references :trainee,  :null => false
      t.integer :education_level
      t.string :recent_employer
      t.string :job_title
      t.integer :years
      t.text :certifications

      t.timestamps
    end
    add_index :tact_threes, [:account_id, :trainee_id]

  end
end
