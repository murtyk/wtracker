class RemoveFkOnUserEmployerSources < ActiveRecord::Migration
  def change
    remove_foreign_key :employer_files, :accounts
    remove_foreign_key :employer_files, :employers
    remove_foreign_key :employer_files, :users
    remove_foreign_key :employer_sources, :accounts
    remove_foreign_key :employers, :employer_sources
    remove_foreign_key :grant_trainee_statuses, :accounts
    remove_foreign_key :grant_trainee_statuses, :grants
    remove_foreign_key :trainee_statuses, :accounts
    remove_foreign_key :trainee_statuses, :grant_trainee_statuses
    remove_foreign_key :trainee_statuses, :grants
    remove_foreign_key :trainee_statuses, :trainees
    remove_foreign_key :user_employer_sources, :accounts
    remove_foreign_key :user_employer_sources, :employer_sources
    remove_foreign_key :user_employer_sources, :users
  end
end
