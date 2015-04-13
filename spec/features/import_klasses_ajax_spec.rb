require 'rails_helper'

describe 'Importer' do
  describe 'imports' do
    before(:each) do
      signin_admin

      @filepath = "#{Rails.root}/spec/fixtures/classes.xlsx"

      allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
    end

    it 'classes', js: true do
      Delayed::Worker.delay_jobs = false
      visit '/import_statuses/new?resource=klasses'
      attach_file 'file', @filepath
      select('Big program 1', from: 'program_id')
      select('Bucks county community college', from: 'college_id')
      click_button 'Import'
      wait_for_ajax
      expect(page).to have_text 'Class A1'
      expect(page).to have_text 'Class B1'
    end
  end
end
