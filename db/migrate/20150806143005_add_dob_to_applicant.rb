# frozen_string_literal: true

class AddDobToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :dob, :date
  end
end
