# frozen_string_literal: true

class CreateKlassEvents < ActiveRecord::Migration
  def change
    create_table :klass_events do |t|
      t.references :account, null: false
      t.references :klass
      t.string :name
      t.date :event_date

      t.timestamps
    end
    add_index :klass_events, %i[account_id klass_id]
  end
end
