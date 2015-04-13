require 'rails_helper'

describe 'password' do
  describe 'can change password' do
    it 'changes password' do
      signin_admin

      # visit('/users/edit_password')
      find(:xpath, "//a[@href='/users/edit_password']").click

      fill_in 'user_password', with: 'secret1'
      fill_in 'user_password_confirmation', with: 'secret12'

      click_on 'Change my password'

      expect(page).to have_text("doesn't match")

      fill_in 'user_password', with: 'secret1'
      fill_in 'user_password_confirmation', with: 'secret1'

      click_on 'Change my password'
      expect(page).to have_text('is too short (minimum is 8 characters)')

      fill_in 'user_password', with: 'secret12'
      fill_in 'user_password_confirmation', with: 'secret12'

      click_on 'Change my password'
      expect(page).to have_text('Password successfully updated')

      find(:xpath, "//a[@href='/logout']").click

      visit root_path
      fill_in 'user_email', with: 'ballu@mail.com'
      fill_in 'password', with: 'secret12'
      click_button 'Sign in'

      expect(page).to have_text('Signed in successfully.')
    end
  end
end
