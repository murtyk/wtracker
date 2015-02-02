class CreateAutoLeadEmailTexts < ActiveRecord::Migration
  def change
    create_table :auto_lead_email_texts do |t|
      t.string :type
      t.text :content
      t.references :account, index: true
      t.references :grant, index: true

      t.timestamps
    end
  end
end
