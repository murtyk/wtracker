class AddCategoryToKlasses < ActiveRecord::Migration
  def change
    add_reference :klasses, :klass_category, index: true
    add_foreign_key :klasses, :klass_categories
  end
end
