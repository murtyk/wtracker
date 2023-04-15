# frozen_string_literal: true
require 'rails_helper'

describe 'Administration' do
  describe 'counties' do
    before(:each) do
      signin_opero_admin
    end
    it 'search' do
      visit '/admin/counties'
      select 'New Jersey', from: 'filters_state_id'
      click_on 'Find'
      expect(page).to have_text('Camden')
    end
  end
end
