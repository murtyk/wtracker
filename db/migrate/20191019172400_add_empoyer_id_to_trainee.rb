class AddEmpoyerIdToTrainee < ActiveRecord::Migration
  def change
    add_reference :trainees, :employer, index: true
    add_foreign_key :trainees, :employers
  end
end
