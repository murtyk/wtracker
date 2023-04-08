# frozen_string_literal: true

class RemoveSourceFromEmployers < ActiveRecord::Migration
  def change
    remove_column :employers, :source, :string
  end
end
