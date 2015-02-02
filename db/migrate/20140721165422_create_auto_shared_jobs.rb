class CreateAutoSharedJobs < ActiveRecord::Migration
  def change
    create_table :auto_shared_jobs do |t|
      t.references :account
      t.references :trainee, index: true
      t.string :title
      t.string :company
      t.datetime :date_posted
      t.string :location
      t.text :excerpt
      t.text :url
      t.integer :status
      t.text :feedback
      t.string :key

      t.timestamps
    end
  end
end
