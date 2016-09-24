class CreateUiVerifiedNotes < ActiveRecord::Migration
  def change
    create_table :ui_verified_notes do |t|
      t.references :user, index: true
      t.text :notes
      t.references :trainee, index: true

      t.timestamps null: false
    end
    add_foreign_key :ui_verified_notes, :users
    add_foreign_key :ui_verified_notes, :trainees
  end
end
