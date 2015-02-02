require 'rails_helper'

describe "Reports" do
  describe 'Trainees', js: true do
    before :each do
      signin_admin
    end

    after :each do
      signout
    end

    it 'near by employers' do
      visit "/reports/new?report=#{Report::TRAINEES_NEAR_BY_EMPLOYERS}"
      select 'CNC 101', from: 'filters_klass_id'
      select 'manufacturing', from: 'filters_sector_id'
      fill_in 'filters_distance', with: '25'
      click_on 'Find'
      sleep 3
      wait_for_ajax
      expect(page).to have_text "Paul Harris"
      expect(page).to have_text "Trigyn"
    end
  end
end
