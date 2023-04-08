# frozen_string_literal: true

class CreateTraineeNotes < ActiveRecord::Migration
  def change
    create_table :trainee_notes do |t|
      t.text :notes

      t.timestamps
    end
  end
end
