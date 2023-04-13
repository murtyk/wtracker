# frozen_string_literal: true

class CreateKlassTitles < ActiveRecord::Migration
  def change
    create_table :klass_titles do |t|
      t.references :account, null: false
      t.references :klass, null: false
      t.string :title

      t.timestamps
    end
    add_index :klass_titles, %i[account_id klass_id]
  end
end
