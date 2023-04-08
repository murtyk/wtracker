# frozen_string_literal: true

class AddIndexToApplicants < ActiveRecord::Migration
  def change
    add_index :applicants, :email, unique: true
  end
end
