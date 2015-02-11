class CreateEmployerFiles < ActiveRecord::Migration
  def change
    create_table :employer_files do |t|
      t.references :account, index: true
      t.references :employer, index: true
      t.string :file
      t.references :user, index: true
      t.string :notes

      t.timestamps null: false
    end
    add_foreign_key :employer_files, :accounts
    add_foreign_key :employer_files, :employers
    add_foreign_key :employer_files, :users
  end
end
