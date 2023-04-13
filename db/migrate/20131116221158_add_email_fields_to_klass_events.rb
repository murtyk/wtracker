# frozen_string_literal: true

class AddEmailFieldsToKlassEvents < ActiveRecord::Migration
  def change
    add_column :klass_events, :uid, :string
    add_column :klass_events, :sequence, :integer
  end
end
