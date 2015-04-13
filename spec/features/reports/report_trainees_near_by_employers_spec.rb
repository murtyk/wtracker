require 'rails_helper'

describe 'Reports' do
  describe 'Trainees', js: true do
    before :each do
      signin_admin
    end

    after :each do
      signout
    end

    it 'near by employers' do
      visit_report Report::TRAINEES_NEAR_BY_EMPLOYERS
      select 'CNC 101', from: 'Class'
      select 'manufacturing', from: 'Sector'
      fill_in 'Distance', with: '25'
      click_on 'Find'
      sleep 3
      wait_for_ajax
      expect(page).to have_text 'Paul Harris'
      expect(page).to have_text 'Trigyn'
    end
  end
end
