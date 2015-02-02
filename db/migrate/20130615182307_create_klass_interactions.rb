class CreateKlassInteractions < ActiveRecord::Migration
  def change
    create_table :klass_interactions do |t|
      t.references :account,  :null => false
      t.references :grant,  :null => false
      t.references :employer,  :null => false
      t.references :klass_event,  :null => false
      t.integer :status

      t.timestamps
    end
    add_index :klass_interactions, [:account_id, :grant_id, :employer_id], name: "klass_interactions_employer_id_index"
    add_index :klass_interactions, [:account_id, :grant_id, :klass_event_id], name: "klass_interactions_klass_event_id_index"
  end
end
