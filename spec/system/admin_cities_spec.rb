# frozen_string_literal: true
require 'rails_helper'

describe 'Administration' do
  describe 'cities' do
    before(:each) do
      signin_opero_admin

      @filepath = "#{Rails.root}/spec/fixtures/cities.xlsx"
      allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
    end
    it 'search', skip: true do
      visit '/admin/cities'
      select 'New Jersey', from: 'filters_state_id'
      click_on 'Find'
      expect(page).to have_text('Edison')
    end
    it 'import', js: true, skip: true do
      VCR.use_cassette('cities') do
        Delayed::Worker.delay_jobs = false
        visit '/admin/import_statuses/new?resource=cities'
        attach_file 'file', @filepath
        click_button 'Import'
        wait_for_ajax
        visit '/admin/import_statuses/' + ImportStatus.unscoped.last.id.to_s
        expect(page).to have_text 'invalid longitude'
        expect(page).to have_text 'invalid latitude'
        expect(page).to have_text 'invalid zip code'
        expect(page).to have_text 'state does not exist'
        expect(page).to have_text 'not found in state'
        expect(page).to have_text 'city already exists'
        expect(page).to have_text 'county bad not found in state NH'

        expect(page).to have_text 'Groveton'
        expect(page).to have_text '03582'
      end
    end
  end
end
