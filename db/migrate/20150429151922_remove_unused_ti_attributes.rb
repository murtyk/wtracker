class RemoveUnusedTiAttributes < ActiveRecord::Migration
  def change
    remove_column :trainee_interactions, :interview_date
    remove_column :trainee_interactions, :interviewer
    remove_column :trainee_interactions, :offer_date
    remove_column :trainee_interactions, :offer_salary
    remove_column :trainee_interactions, :offer_title
  end
end
