class CreateApplicantReapplies < ActiveRecord::Migration
  def change
    create_table :applicant_reapplies do |t|
      t.references :applicant, index: true
      t.references :account, index: true
      t.references :grant, index: true
      t.string :key
      t.boolean :used

      t.timestamps
    end
  end
end
