# frozen_string_literal: true

class AddSourceToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :source, :string
  end
end
