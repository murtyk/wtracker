class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :account
      t.string :subject
      t.text :content
      t.references :user

      t.timestamps
    end
    add_index :emails, :account_id
    add_index :emails, :user_id
  end
end
