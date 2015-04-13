require 'rails_helper'

describe 'Company' do
  describe 'google search' do
    before :each do
      signin_admin
    end

    it 'companies' do
      visit('/employers/search_google')
      VCR.use_cassette('companies_google_search') do
        fill_in 'filters_name', with: 'Munich Re'
        fill_in 'filters_location', with: 'Princeton, NJ'
        click_on 'Find'
        expect(page).to have_text 'Munich Reinsurance America, Inc'
      end
    end
  end
end
