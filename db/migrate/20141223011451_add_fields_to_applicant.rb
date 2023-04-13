# frozen_string_literal: true

class AddFieldsToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :gender, :string
    add_column :applicants, :last_employer_manager_name, :string
    add_column :applicants, :last_employer_manager_phone_no, :string
    add_column :applicants, :last_employer_manager_email, :string
    add_column :applicants, :last_employer_line1, :string
    add_column :applicants, :last_employer_line2, :string
    add_column :applicants, :last_employer_zip, :string
    add_column :applicants, :last_wages, :string
  end
end
