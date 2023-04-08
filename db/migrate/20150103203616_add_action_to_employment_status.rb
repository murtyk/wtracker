# frozen_string_literal: true

class AddActionToEmploymentStatus < ActiveRecord::Migration
  def change
    add_column :employment_statuses, :action, :string
    add_column :employment_statuses, :email_subject, :string
    add_column :employment_statuses, :email_body, :text
  end
end
