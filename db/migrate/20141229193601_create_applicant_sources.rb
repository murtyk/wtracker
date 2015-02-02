class CreateApplicantSources < ActiveRecord::Migration
  def change
    create_table :applicant_sources do |t|
      t.string :source
      t.references :account, index: true
      t.references :grant, index: true

      t.timestamps
    end
  end
end
