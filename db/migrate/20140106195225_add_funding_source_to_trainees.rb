class AddFundingSourceToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :funding_source_id, :integer
  end
end
