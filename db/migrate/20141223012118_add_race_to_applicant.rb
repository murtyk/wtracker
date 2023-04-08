# frozen_string_literal: true

class AddRaceToApplicant < ActiveRecord::Migration
  def change
    add_reference :applicants, :race, index: true
  end
end
