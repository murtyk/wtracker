class CreateApplicants < ActiveRecord::Migration
  def change
    create_table :applicants do |t|
      t.references :account, null: false, index: true
      t.references :grant,   null: false, index: true
      t.references :trainee,              index: true
      t.string :first_name
      t.string :last_name
      t.string :address_line1
      t.string :address_line2
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.string :email
      t.string :mobile_phone_no
      t.date :last_employed_on
      t.string :current_employment_status
      t.string :last_job_title
      t.string :salary_expected
      t.string :education_level
      t.boolean :transportation
      t.boolean :computer_access
      t.text :resume
      t.string :reference
      t.boolean :signature
      t.text :comments
      t.string :status

      t.timestamps
    end
  end
end
