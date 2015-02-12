class CreateGrantTraineeStatuses < ActiveRecord::Migration
  def change
    create_table :grant_trainee_statuses do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :grant_trainee_statuses, :accounts
    add_foreign_key :grant_trainee_statuses, :grants
  end
end
