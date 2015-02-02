class CreateKlassInstructors < ActiveRecord::Migration
  def change
    create_table :klass_instructors do |t|
      t.references :account,  :null => false
      t.references :klass
      t.references :user

      t.timestamps
    end
    add_index :klass_instructors, [:account_id, :klass_id]
    add_index :klass_instructors, [:account_id, :user_id]
  end
end
