# frozen_string_literal: true

class AddOptionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :options, :text
  end
end
