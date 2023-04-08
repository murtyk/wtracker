# frozen_string_literal: true

class CreateKlassTrainees < ActiveRecord::Migration
  def change
    create_table :klass_trainees do |t|
      t.references :account, null: false
      t.references :klass, null: false
      t.references :trainee, null: false
      t.integer :status

      t.timestamps
    end
    add_index :klass_trainees, %i[account_id klass_id]
    add_index :klass_trainees, %i[account_id trainee_id]
  end
end
