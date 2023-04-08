# frozen_string_literal: true

class AddUiClaimVerifiedOnToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :ui_claim_verified_on, :date
  end
end
