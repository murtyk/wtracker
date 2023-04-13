# frozen_string_literal: true

class AddGtsIdToTrainee < ActiveRecord::Migration
  def change
    add_column :trainees, :gts_id, :integer
  end
end
