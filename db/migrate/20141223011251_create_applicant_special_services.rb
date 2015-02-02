class CreateApplicantSpecialServices < ActiveRecord::Migration
  def change
    create_table :applicant_special_services do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.references :special_service, index: true
      t.references :applicant, index: true

      t.timestamps
    end
  end
end
