class CreateSpecialServices < ActiveRecord::Migration
  def change
    create_table :special_services do |t|
      t.references :account, index: true
      t.references :grant, index: true
      t.string :name

      t.timestamps
    end
  end
end
