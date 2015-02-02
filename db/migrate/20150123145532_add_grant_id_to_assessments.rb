class AddGrantIdToAssessments < ActiveRecord::Migration
  def change
    add_reference :assessments, :grant, index: true
  end
end
