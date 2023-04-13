# frozen_string_literal: true

class RemoveAutoleadfieldsFromGrant < ActiveRecord::Migration
  def change
    remove_column :grants, :profile_request_subject, :string
    remove_column :grants, :profile_request_text, :text
    remove_column :grants, :job_leads_subject, :string
    remove_column :grants, :job_leads_text, :text
  end
end
