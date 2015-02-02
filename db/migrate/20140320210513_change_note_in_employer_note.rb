class ChangeNoteInEmployerNote < ActiveRecord::Migration
  def change
  	change_column :employer_notes, :note, :text
  end
end
