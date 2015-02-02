require 'rails_helper'

describe "Dashboard" do
  describe "director user" do
    it "shows programs and classes" do
        signin_director
        Account.current_id = 1
        Grant.current_id = 1
        Klass.all.each do |klass|
            expect(page).to have_text klass.name
        end
    end
  end

  describe "admin user" do
    it "shows programs and classes" do
        signin_admin
        Account.current_id = 1
        Grant.current_id = 1
        Klass.all.each do |klass|
            expect(page).to have_text klass.name
        end
    end
  end

end
