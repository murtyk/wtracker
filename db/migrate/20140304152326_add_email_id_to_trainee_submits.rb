# frozen_string_literal: true

class AddEmailIdToTraineeSubmits < ActiveRecord::Migration
  def change
    add_reference :trainee_submits, :email, index: true
  end
end
