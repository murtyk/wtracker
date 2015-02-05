require 'rails_helper'

describe "Dashboard" do
  describe "navigator" do
    it "shows interviews and visit events" do
      Account.current_id = 1
      melinda = User.where(email: 'melinda@mail.com').first
      grant = Grant.first
      Grant.current_id = grant.id
      klass = Klass.first
      klass.navigators << melinda

      signin_navigator

      expect(page).to_not have_text 'Interviews'

      visit '/dashboards/summary'
      # click_on 'Dashboard'
      expect(page).to have_text 'Interviews'
      expect(page).to have_text 'Visits'

      signout
      signin_admin

      destroy_klasses
    end
  end
end
