class AddEmployerSourceToEmployer < ActiveRecord::Migration
  def change
    add_reference :employers, :employer_source, index: true
    add_foreign_key :employers, :employer_sources
  end
end
