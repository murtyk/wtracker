require 'rails_helper'
describe 'emails' do
  describe 'create, show, list', js: true do
    before :each do
      signin_admin
    end

    it 'create, show, list and delete' do
      visit('/emails/new')
      find_field('Subject').set 'Testing Email'
      # fill_in 'Subject', with: 'Testing Email'
      fill_in 'Content', with: 'Hello, how are you?'

      fill_in 'name', with: 'w'
      click_on 'Find'
      wait_for_ajax

      expect(page).to have_text 'Wawa'
      select('Johnny Darko(Wawa)', from: 'select_contacts')
      click_button 'add-selected-contacts'

      fill_in 'name', with: ''
      select 'manufacturing', from: 'sector_id'
      select 'NJ - Middlesex', from: 'county_id'
      click_on 'Find'
      wait_for_ajax
      expect(page).to have_text 'Trigyn'
      select('Mason Saari(Trigyn)', from: 'select_contacts')
      click_button 'add-selected-contacts'

      click_button 'Send'
      expect(page).to have_text 'email was successfully scheduled for delivery.'
      expect(page).to have_text 'Hello, how are you?'

      visit('/emails')
      expect(page).to have_text 'Hello, how are you?'

      Account.current_id = 1

      Email.all.each do |email|
        click_link destroy_link_id(email)
        page.driver.browser.switch_to.alert.accept
        wait_for_ajax
      end

      expect(page).to_not have_text 'Hello, how are you?'
    end
  end
end
