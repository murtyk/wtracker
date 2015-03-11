require 'rails_helper'

describe "companies finder" do
  before(:each) do
    signin_admin

    @filepath = "#{Rails.root}/spec/fixtures/search_companies.xlsx"
    allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
    allow(Amazon).to receive(:file_url).and_return(@filepath)
  end

  it "processes", js: true do
    VCR.use_cassette('companies_finder') do
      Delayed::Worker.delay_jobs = false
      visit '/companies_finder/new'
      attach_file "file", @filepath
      click_button 'Process'
      wait_for_ajax
      expect(page).to have_text 'Not Found'
      expect(page).to have_text '(609) 465-1368'

      select 'banking', from: 'sector_ids'
      click_button 'Select All'
      click_button 'Add Selected'
      wait_for_ajax

      expect(page).to have_text 'city not found'
      expect(page).to have_text 'added'

    end
  end
end