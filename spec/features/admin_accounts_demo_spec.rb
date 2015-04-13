require 'rails_helper'

describe 'Administration' do
  describe 'accounts' do
    it 'can provision a demo account' do
      signin_opero_admin
      click_on 'New Account'

      check 'Create Demo Data'
      fill_in 'Name', with: 'Demo Client', match: :prefer_exact
      fill_in 'Description', with: 'Demo Client for testing'
      fill_in 'Subdomain', with: 'demo'
      select('Grant Recipient', from: 'Client Type')
      select('Active', from: 'Status')

      fill_in 'First Name', with: 'Brinjal'
      fill_in 'Last Name', with: 'Curry'
      fill_in 'Email', with: 'brinjal@mail.com'
      fill_in 'Password', with: 'password'
      fill_in 'Location', with: 'Edison, NJ'

      click_on 'Save'

      expect(page).to have_text 'Please wait for a minute to generate ' \
                                'data for this demo account'
      Delayed::Worker.new.work_off
      signout_opero_admin

      sign_in_demo_user
      visit '/klasses'
      expect(page).to have_text 'CNC 101'
      signout
    end
  end
end
