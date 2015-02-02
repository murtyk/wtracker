class CreateJobOpenings < ActiveRecord::Migration
  def change
    create_table :job_openings do |t|
      t.integer :jobs_no
      t.string :skills
      t.references :employer,  :null => false
      t.references :account,  :null => false

      t.timestamps
    end
    add_index :job_openings, [:account_id, :employer_id]
  end
end
