# frozen_string_literal: true

class AddTdcAttributesToTactThree < ActiveRecord::Migration
  def change
    add_column :tact_threes, :current_employment_status, :string
    add_column :tact_threes, :last_wages, :string
    add_column :tact_threes, :last_employed_on, :date
  end
end
