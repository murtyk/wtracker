class CreateHotJobs < ActiveRecord::Migration
  def change
    create_table :hot_jobs do |t|
      t.references :account, index: true
      t.references :user, index: true
      t.references :employer, index: true
      t.date :date_posted
      t.date :closing_date
      t.string :title
      t.string :description
      t.string :salary
      t.string :location

      t.timestamps null: false
    end
    add_foreign_key :hot_jobs, :accounts
    add_foreign_key :hot_jobs, :users
    add_foreign_key :hot_jobs, :employers
  end
end
