# frozen_string_literal: true

class CreateUserCounties < ActiveRecord::Migration
  def change
    create_table :user_counties do |t|
      t.references :account, index: true
      t.references :user, index: true
      t.references :county, index: true

      t.timestamps
    end
  end
end
