# frozen_string_literal: true

class CreateLeadsQueues < ActiveRecord::Migration
  def change
    create_table :leads_queues do |t|
      t.references :trainee, index: true
      t.integer :status, default: 0
      t.hstore :data

      t.timestamps null: false
    end
    add_foreign_key :leads_queues, :trainees
  end
end
