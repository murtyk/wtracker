class AddLoginIdToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :login_id, :string
    add_index  :trainees, :login_id, unique: true
  end
end
