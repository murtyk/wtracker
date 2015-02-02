class CreateJobSearches < ActiveRecord::Migration
  def change
    create_table :job_searches do |t|
      t.string :keywords
      t.string :location
      t.references :user
      t.references :account,  :null => false

      t.integer :distance
      t.integer :recruiters
      t.integer :days
      t.integer :klass_title_id
      t.integer :count

      t.timestamps
    end
    add_index :job_searches, [:account_id, :user_id]
    add_index :job_searches, :account_id
  end
end


