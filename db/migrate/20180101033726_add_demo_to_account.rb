class AddDemoToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :demo, :boolean
  end
end
