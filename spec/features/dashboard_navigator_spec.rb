require 'rails_helper'

describe "Dashboard" do

  describe "navigator", js: true do
    it "shows interviews and visit events" do

      signin_admin
      destroy_klasses
      create_klasses(1)
      click_link 'new_klass_navigator_link'
      wait_for_ajax
      select('Melinda Peters', from: 'klass_navigator_user_id')
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'Melinda Peters'

      signout
      signin_navigator

      expect(page).to_not have_text 'Interviews'
      page.driver.browser.manage().window().maximize()

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
