require 'rails_helper'

describe 'Employers' do
  describe 'import' do
    before(:each) do
      signin_admin

      @filepath = "#{Rails.root}/spec/fixtures/employers.xlsx"
      allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
    end

    after(:each) do
      destroy_employers
    end

    it 'excel file', js: true do
      VCR.use_cassette('employers_import') do
        Delayed::Worker.delay_jobs = false
        visit '/import_statuses/new?resource=employers'
        attach_file 'file', @filepath
        select 'health', from: 'sector_ids_'
        select 'insurance', from: 'sector_ids_'
        click_button 'Import'
        wait_for_ajax
        visit '/import_statuses/' + ImportStatus.unscoped.last.id.to_s
        expect(page).to have_text 'Ferro Corporation'
        expect(page).to have_text 'Geocoding failed for address'
        click_on 'Retry'
        wait_for_ajax
        expect(page).to have_text 'Retry Failed'
      end
    end
  end
end
