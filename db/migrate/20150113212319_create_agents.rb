# frozen_string_literal: true

class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.hstore :info
      t.references :identifiable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
