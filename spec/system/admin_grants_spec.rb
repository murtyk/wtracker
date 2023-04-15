# frozen_string_literal: true
require 'rails_helper'

describe 'Administration' do
  describe 'grants' do
    before(:each) do
      signin_opero_admin
    end

    it 'update' do
      expect(page).to have_text 'Accounts'
      click_on 'PAWF Org'
      expect(page).to have_text 'Big Grant'

      account = Account.where(name: 'PAWF Org').first
      Account.current_id = account.id
      grant = account.grants.first
      click_link edit_link_id(grant)

      fill_in 'Name', with: 'Very Big Grant', match: :prefer_exact
      click_on 'Update'
      expect(page).to have_text 'Grant was successfully updated.'
    end
  end
end
