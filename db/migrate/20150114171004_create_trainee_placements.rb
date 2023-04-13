# frozen_string_literal: true

class CreateTraineePlacements < ActiveRecord::Migration
  def change
    create_table :trainee_placements do |t|
      t.references :account, index: true
      t.references :trainee, index: true
      t.hstore :info

      t.timestamps
    end
    add_index(:trainee_placements, :info, using: 'GIN')
  end
end
