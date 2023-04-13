# frozen_string_literal: true

class AddCompanyToTraineeInteraction < ActiveRecord::Migration
  def change
    add_column :trainee_interactions, :company, :string
  end
end
