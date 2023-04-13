# frozen_string_literal: true

class AddRegistrationDateToTactThree < ActiveRecord::Migration
  def change
    add_column :tact_threes, :registration_date, :date
  end
end
