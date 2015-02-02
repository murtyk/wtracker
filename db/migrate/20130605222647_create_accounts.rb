class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name,			:null => false
      t.string :description,	:null => false
      t.integer :client_type,	:null => false
      t.integer :status,		:null => false
      t.string :subdomain,		:null => false
      t.string :logo_file

      t.timestamps
    end
  end
end
