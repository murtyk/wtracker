require 'rails_helper'

describe 'Funding Sources' do
  describe 'can list, add and delete' do
    before :each do
      signin_college_director
      visit('/funding_sources')
    end

    it 'can add and delete funding_source', js: true do
      click_on 'New'
      wait_for_ajax
      fill_in 'funding_source_name', with: 'FundingSource1'
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'FundingSource1'

      funding_source = FundingSource.unscoped.where(name: 'FundingSource1').first
      id = "destroy_funding_source_#{funding_source.id}_link"
      AlertConfirmer.accept_confirm_from do
        click_link id

      end
      wait_for_ajax
      expect(page).to_not have_text 'FundingSource1'
    end
  end
end
