# frozen_string_literal: true

class AddEdpDateToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :edp_date, :date
  end
end
