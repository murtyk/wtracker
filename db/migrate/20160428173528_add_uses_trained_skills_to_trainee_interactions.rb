class AddUsesTrainedSkillsToTraineeInteractions < ActiveRecord::Migration
  def change
    add_column :trainee_interactions, :uses_trained_skills, :string
  end
end
