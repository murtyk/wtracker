class DropProgramInterestTable < ActiveRecord::Migration
  def change
    drop_table :program_interests
  end
end
