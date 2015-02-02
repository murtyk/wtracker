class CreateKlassCertificates < ActiveRecord::Migration
  def change
    create_table :klass_certificates do |t|
      t.references :account,  :null => false
      t.references :klass
      t.string :name
      t.string :description

      t.timestamps
    end
    add_index :klass_certificates, [:account_id, :klass_id]
  end
end
