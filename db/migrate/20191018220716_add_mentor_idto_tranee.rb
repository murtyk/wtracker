# frozen_string_literal: true

class AddMentorIdtoTranee < ActiveRecord::Migration
  def change
    add_reference :trainees, :mentor, index: true
  end
end
