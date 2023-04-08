# frozen_string_literal: true

class AddWebsiteToEmployers < ActiveRecord::Migration
  def change
    add_column :employers, :website, :string
  end
end
