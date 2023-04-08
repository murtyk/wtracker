# frozen_string_literal: true

class AddEncryptedTraineeIdToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :encrypted_trainee_id, :string
  end
end
