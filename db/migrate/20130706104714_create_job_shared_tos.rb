class CreateJobSharedTos < ActiveRecord::Migration
  def change
    create_table :job_shared_tos do |t|
      t.references :account,  :null => false
      t.references :job_share,  :null => false
      t.references :trainee,  :null => false

      t.timestamps
    end
    add_index :job_shared_tos, [:account_id, :job_share_id]
    add_index :job_shared_tos, [:account_id, :trainee_id]
  end
end
