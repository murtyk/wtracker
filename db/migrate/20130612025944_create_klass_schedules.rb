# frozen_string_literal: true

class CreateKlassSchedules < ActiveRecord::Migration
  def change
    create_table :klass_schedules do |t|
      t.references :account, null: false
      t.references :klass
      t.boolean :scheduled
      t.integer :dayoftheweek
      t.integer :start_time_hr
      t.integer :start_time_min
      t.string :start_ampm
      t.integer :end_time_hr
      t.integer :end_time_min
      t.string :end_ampm

      t.timestamps
    end
    add_index :klass_schedules, %i[account_id klass_id]
  end
end
