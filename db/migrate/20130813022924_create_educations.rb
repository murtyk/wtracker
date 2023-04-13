# frozen_string_literal: true

class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations do |t|
      t.string :name

      t.timestamps
    end
  end
end
