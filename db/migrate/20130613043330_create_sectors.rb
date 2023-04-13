# frozen_string_literal: true

class CreateSectors < ActiveRecord::Migration
  def change
    create_table :sectors do |t|
      t.string :name

      t.timestamps
    end
  end
end
