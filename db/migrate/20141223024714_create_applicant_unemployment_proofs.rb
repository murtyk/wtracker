class CreateApplicantUnemploymentProofs < ActiveRecord::Migration
  def change
    create_table :applicant_unemployment_proofs do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.references :unemployment_proof, index: true
      t.references :applicant, index: true

      t.timestamps
    end
  end
end
