# frozen_string_literal: true

class DropDemoColumnFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :demo
  end
end
