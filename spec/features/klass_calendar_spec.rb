require 'rails_helper'

describe "Klass Calendar" do
  describe 'can do events' do

    before :each do
      signin_admin
    end

    it 'will not have a calendar when start and end dates are missing' do
      visit '/klasses'
      page.first(:css, '#new_klass_link').click
      fill_in 'Name', with: 'Fab Metals 1'
      click_on 'Save'

      expect(page).to have_text 'Please define start and end dates for the class'
    end

    it 'will have a calendar when start and end dates are provided' do
      visit '/klasses'
      page.first(:css, '#new_klass_link').click
      fill_in 'Name', with: 'Fab Metals 2'
      fill_in 'Start date', with: '01/01/2014'
      fill_in 'End date', with: '12/31/2015'
      click_on 'Save'

      expect(page).to_not have_text 'Please define start and end dates for the class'
      expect(page).to have_selector("th", text: "01-Jan")
      expect(page).to have_selector("th", text: "31-Dec")
      expect(page).to have_selector("td", text: "Information Session")
    end

    it "will go to klass event page when clicked on event in calendar" do
      pending 'need to figure out how to click a cell in table'
      fail
      # visit '/klasses'
      # page.first(:css, '#new_klass_link').click
      # fill_in 'Name', with: 'Fab Metals 2'
      # fill_in 'Start date', with: '01/01/2014'
      # fill_in 'End date', with: '12/31/2014'
      # click_on 'Save'

      # cell = find('td', text: "Information Session")
      # puts cell.inspect
      # cell.click
      # sleep 0.5
      # expect(page).to have_text 'Class Event'
      # expect(page).to have_text 'Select Employers and Add them for interaction'
  end


  end
end