# frozen_string_literal: true

class AddNotesToKlassEvents < ActiveRecord::Migration
  def change
    add_column :klass_events, :notes, :string
  end
end
