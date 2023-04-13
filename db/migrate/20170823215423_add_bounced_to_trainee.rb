# frozen_string_literal: true

class AddBouncedToTrainee < ActiveRecord::Migration
  def change
    add_column :trainees, :bounced, :boolean
  end
end
