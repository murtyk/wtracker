# frozen_string_literal: true

class AddAuthTokenToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :auth_token, :string, default: ''
    add_index :admins, :auth_token, unique: true
  end
end
