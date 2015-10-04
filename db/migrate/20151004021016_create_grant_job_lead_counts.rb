class CreateGrantJobLeadCounts < ActiveRecord::Migration
  def change
    create_table :grant_job_lead_counts do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.date :sent_on
      t.integer :count

      t.timestamps null: false
    end
    add_foreign_key :grant_job_lead_counts, :accounts
    add_foreign_key :grant_job_lead_counts, :grants
  end
end
