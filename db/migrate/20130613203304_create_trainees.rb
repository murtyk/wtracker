class CreateTrainees < ActiveRecord::Migration
  def change
    create_table :trainees do |t|
      t.string :first
      t.string :middle
      t.string :last
      t.integer :status
      t.string :trainee_id
      t.date :dob
      t.string :gender
      t.string :disability
      t.boolean :veteran
      t.string :education
      t.string :land_no
      t.string :mobile_no
      t.string :email
      t.string :skills_experience
      t.references :account,     :null => false
      t.references :grant, :null => false

      t.timestamps
    end
    add_index :trainees, [:account_id, :grant_id]
  end
end
