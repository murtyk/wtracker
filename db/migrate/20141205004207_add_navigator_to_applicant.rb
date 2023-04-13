# frozen_string_literal: true

class AddNavigatorToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :navigator_id, :integer
  end
end
