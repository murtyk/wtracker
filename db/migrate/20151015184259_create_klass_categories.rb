class CreateKlassCategories < ActiveRecord::Migration
  def change
    create_table :klass_categories do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.string :code, null: false
      t.string :description, null: false

      t.timestamps null: false
    end
    add_foreign_key :klass_categories, :accounts
    add_foreign_key :klass_categories, :grants
  end
end
