class CreateEmployers < ActiveRecord::Migration
  def change
    create_table :employers do |t|
      t.string :name
      t.string :source
      t.references :account, :null => false

      t.timestamps
    end
    add_index :employers, :account_id
    add_index :employers, [:account_id, :source]

  end
end
