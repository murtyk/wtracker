# frozen_string_literal: true

class AddLastActivityAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_activity_at, :datetime
  end
end
