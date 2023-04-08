# frozen_string_literal: true

class AddGrantIdToFundingSource < ActiveRecord::Migration
  def change
    add_column :funding_sources, :grant_id, :integer
  end
end
