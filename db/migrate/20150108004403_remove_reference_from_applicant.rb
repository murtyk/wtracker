# frozen_string_literal: true

class RemoveReferenceFromApplicant < ActiveRecord::Migration
  def change
    remove_column :applicants, :reference
  end
end
