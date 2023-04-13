# frozen_string_literal: true

class AddPositionToEducation < ActiveRecord::Migration
  def change
    add_column :educations, :position, :integer
  end
end
