# frozen_string_literal: true

class AddDisableAttrsToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :disabled_date, :date
    add_column :trainees, :disabled_notes, :string
  end
end
