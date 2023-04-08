# frozen_string_literal: true

class AddUnemploymentProofToApplicants < ActiveRecord::Migration
  def change
    add_column :applicants, :unemployment_proof, :string
  end
end
