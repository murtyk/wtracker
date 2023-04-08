# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.references :account, index: true
      t.references :email, index: true
      t.string :name
      t.string :file

      t.timestamps
    end
  end
end
