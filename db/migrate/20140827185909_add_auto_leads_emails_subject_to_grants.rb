class AddAutoLeadsEmailsSubjectToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :profile_request_subject, :string
    add_column :grants, :job_leads_subject, :string
  end
end
