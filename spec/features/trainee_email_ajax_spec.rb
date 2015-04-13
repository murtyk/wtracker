require 'rails_helper'
describe 'trainee email' do
  describe 'create, show, list', js: true do
    before :each do
      signin_admin
      create_klasses(1, 2)
    end

    after :each do
      destroy_all_created
    end

    it 'can create and show and list' do
      visit('/trainee_emails/new')
      select('Engineering1', from: 'Select a Class')
      wait_for_ajax
      sleep 1
      select('All', from: 'Select Trainees')
      fill_in 'Subject', with: 'Testing Email'
      fill_in 'Content', with: 'Hello, how are you?'

      click_button 'Send'
      expect(page).to have_text 'email was successfully scheduled for delivery.'
      expect(page).to have_text 'Hello, how are you?'

      visit('/trainee_emails')
      expect(page).to have_text 'Hello, how are you?'
    end
  end
end
