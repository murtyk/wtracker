# frozen_string_literal: true

class DropProgramInterestTable < ActiveRecord::Migration
  def change
    drop_table :program_interests
  end
end
