# frozen_string_literal: true

class AddAppliedOnToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :applied_on, :date
  end
end
