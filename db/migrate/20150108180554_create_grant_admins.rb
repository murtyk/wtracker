# frozen_string_literal: true

class CreateGrantAdmins < ActiveRecord::Migration
  def change
    create_table :grant_admins do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
