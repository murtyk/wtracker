# frozen_string_literal: true

class ChangeSectorIdToNullableInPrograms < ActiveRecord::Migration
  def change
    change_column_null(:programs, :sector_id, true)
  end
end
