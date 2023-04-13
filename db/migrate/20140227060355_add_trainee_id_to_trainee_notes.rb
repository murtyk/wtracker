# frozen_string_literal: true

class AddTraineeIdToTraineeNotes < ActiveRecord::Migration
  def change
    add_reference :trainee_notes, :trainee, index: true
  end
end
