# frozen_string_literal: true

class AddWebsiteToOperoCompanies < ActiveRecord::Migration
  def change
    add_column :opero_companies, :website, :string
  end
end
