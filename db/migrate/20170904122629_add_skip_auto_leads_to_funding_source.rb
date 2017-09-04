class AddSkipAutoLeadsToFundingSource < ActiveRecord::Migration
  def change
    add_column :funding_sources, :skip_auto_leads, :boolean
  end
end
