class AddCategoryRefToKlassCertificate < ActiveRecord::Migration
  def change
    add_reference :klass_certificates, :certificate_category, index: true
    add_foreign_key :klass_certificates, :certificate_categories
  end
end
