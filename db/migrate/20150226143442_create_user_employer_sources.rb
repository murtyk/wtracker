class CreateUserEmployerSources < ActiveRecord::Migration
  def change
    create_table :user_employer_sources do |t|
      t.references :account,         null: false, index: true
      t.references :employer_source, null: false, index: true
      t.references :user,            null: false, index: true

      t.timestamps null: false
    end
    add_foreign_key :user_employer_sources, :accounts
    add_foreign_key :user_employer_sources, :employer_sources
    add_foreign_key :user_employer_sources, :users
  end
end
