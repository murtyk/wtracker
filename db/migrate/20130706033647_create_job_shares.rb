class CreateJobShares < ActiveRecord::Migration
  def change
    create_table :job_shares do |t|
      t.references :account,  :null => false
      t.string :title
      t.string :company
      t.string :date_posted
      t.text :excerpt
      t.string :location
      t.string :source
      t.text :details_url
      t.integer :details_url_type
      t.string :comment
      t.integer :from_id

      t.timestamps
    end
    add_index :job_shares, :account_id
  end
end
