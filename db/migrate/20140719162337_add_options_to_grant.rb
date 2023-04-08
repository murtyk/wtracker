# frozen_string_literal: true

class AddOptionsToGrant < ActiveRecord::Migration
  def change
    add_column :grants, :options, :text
  end
end
