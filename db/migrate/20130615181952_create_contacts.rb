class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :contactable_id
      t.string :contactable_type
      t.string :first
      t.string :last
      t.string :title
      t.string :land_no
      t.string :ext
      t.string :mobile_no
      t.string :email
      t.references :account,  :null => false

      t.timestamps
    end
    add_index :contacts, [:account_id, :contactable_type, :contactable_id], name: "contacts_index"
  end
end
