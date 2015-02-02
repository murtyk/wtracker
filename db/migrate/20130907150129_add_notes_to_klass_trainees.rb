class AddNotesToKlassTrainees < ActiveRecord::Migration
  def change
    add_column :klass_trainees, :notes, :string
  end
end
