# frozen_string_literal: true

class CreateEmploymentStatuses < ActiveRecord::Migration
  def change
    create_table :employment_statuses do |t|
      t.string :status
      t.references :grant, index: true
      t.references :account, index: true

      t.timestamps
    end
  end
end
