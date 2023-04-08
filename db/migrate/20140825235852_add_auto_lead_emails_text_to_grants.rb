# frozen_string_literal: true

class AddAutoLeadEmailsTextToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :profile_request_text, :text
    add_column :grants, :job_leads_text, :text
  end
end
