class AddHstoreToApplicants < ActiveRecord::Migration
  def change
    add_column :applicants, :data, :hstore
  end
end
