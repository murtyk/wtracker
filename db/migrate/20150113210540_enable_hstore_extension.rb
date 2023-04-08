# frozen_string_literal: true

class EnableHstoreExtension < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
  end
end
