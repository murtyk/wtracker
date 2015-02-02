require 'rails_helper'

describe "Dashboard" do

  describe "instructor should not have dashboard" do
    it "does not have dashboard menu" do
      signin_instructor
      expect(page).to_not have_text 'Dashboard'
    end
  end
end
