# frozen_string_literal: true

require 'rails_helper'

describe 'Administration' do
  describe 'manage accounts' do
    before(:each) do
      signin_opero_admin
    end
    it 'can provision a new account' do
      expect(page).to have_text 'Accounts'

      click_on 'New Account'

      fill_in 'Name', with: 'Test Client', match: :prefer_exact
      fill_in 'Description', with: 'Test Client for testing'
      fill_in 'Subdomain', with: 'test'
      select('Grant Recipient', from: 'Client Type')
      select('Active', from: 'Status')

      fill_in 'First Name', with: 'Robin'
      fill_in 'Last Name', with: 'Hood'
      fill_in 'Email', with: 'robin@mail.com'
      fill_in 'Password', with: 'password'
      fill_in 'Location', with: 'Edison, NJ'

      click_on 'Save'

      expect(page).to have_text 'Account was successfully created.'
      click_on 'New Grant'

      fill_in 'Name', with: 'Mega Grant'
      fill_in 'Start date', with: '01/01/2013'
      fill_in 'End date', with: '12/01/2013'
      fill_in 'Trainee Spots', with: '100'
      fill_in 'Grant $ Amount', with: '5000000'
      click_on 'Add'
      expect(page).to have_text 'Grant was successfully created.'
    end

    it 'can update an account' do
      click_on 'Accounts'
      click_on 'PAWF Org'
      click_on 'Edit'
      fill_in 'Name', with: 'Updated Client', match: :prefer_exact
      click_on 'Save'
      expect(page).to have_text 'Account was successfully updated.'
      expect(page).to have_text 'Updated Client'
      click_on 'Accounts'
      expect(page).to have_text 'Updated Client'
    end
  end
end
