require 'rails_helper'

describe 'Google Companies' do
  describe 'search' do
    before :each do
      signin_admin
    end

    it 'finds companies' do
      visit('/google_companies')
      debugger
      VCR.use_cassette('companies_google_search') do
        fill_in 'filters_name', with: 'Munich Re'
        fill_in 'filters_location', with: 'Princeton, NJ'
        click_on 'Find'
        expect(page).to have_text 'Munich Reinsurance America Inc.'
      end
    end
  end
end
