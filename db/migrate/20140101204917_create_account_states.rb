class CreateAccountStates < ActiveRecord::Migration
  def change
    create_table :account_states do |t|
      t.references :account
      t.references :state

      t.timestamps
    end
    add_index :account_states, :account_id
    add_index :account_states, :state_id
  end
end
