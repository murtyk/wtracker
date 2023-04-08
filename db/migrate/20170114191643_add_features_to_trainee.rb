# frozen_string_literal: true

class AddFeaturesToTrainee < ActiveRecord::Migration
  def change
    add_column :trainees, :features, :string, array: true, default: []
  end
end
