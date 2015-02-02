class AddPhoneNoToEmployers < ActiveRecord::Migration
  def change
    add_column :employers, :phone_no, :string
  end
end
