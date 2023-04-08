# frozen_string_literal: true

class ChangeTraineeEmail < ActiveRecord::Migration
  def change
    change_column_null :trainees, :email, false
    change_column_default :trainees, :email, ''
  end
end
