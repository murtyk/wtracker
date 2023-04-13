# frozen_string_literal: true

class AddCountyIdToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :county_id, :integer
  end
end
