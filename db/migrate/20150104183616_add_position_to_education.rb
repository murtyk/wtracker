class AddPositionToEducation < ActiveRecord::Migration
  def change
    add_column :educations, :position, :integer
  end
end
