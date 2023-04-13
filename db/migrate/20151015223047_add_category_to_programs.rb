# frozen_string_literal: true

class AddCategoryToPrograms < ActiveRecord::Migration
  def change
    add_reference :programs, :klass_category, index: true
    add_foreign_key :programs, :klass_categories
  end
end
