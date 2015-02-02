class CreateContactEmails < ActiveRecord::Migration
  def change
    create_table :contact_emails do |t|
      t.references :account
      t.references :email
      t.references :contact

      t.timestamps
    end
    add_index :contact_emails, :account_id
    add_index :contact_emails, :email_id
    add_index :contact_emails, :contact_id
  end
end
