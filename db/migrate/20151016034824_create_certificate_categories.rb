class CreateCertificateCategories < ActiveRecord::Migration
  def change
    create_table :certificate_categories do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.references :account, index: true
      t.references :grant, index: true

      t.timestamps null: false
    end
    add_foreign_key :certificate_categories, :accounts
    add_foreign_key :certificate_categories, :grants
  end
end
