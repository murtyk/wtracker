require 'rails_helper'

describe 'Hot Jobs on Employer Page' do
  include AjaxHelper

  before :each do
    signin_admin
    create_employers(1)
  end
  after :each do
    destroy_employers
  end

  describe 'employer page', js: true do
    it 'adds and deletes an hot job' do
      click_link new_link_id('hot_job')
      wait_for_ajax
      fill_in 'hot_job_title', with: 'Good Title'
      fill_in 'hot_job_location', with: 'Edison, NJ'
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'Good Title'
      expect(page).to_not have_text 'Edison, NJ'

      hot_job = get_employers.first.hot_jobs.first

      desc_id = "hot_job_show_description_#{hot_job.id}"
      page.find_by_id(desc_id).click
      expect(page).to have_text 'Edison, NJ'

      page.find_by_id(destroy_link_id(hot_job)).click
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'Good Title'
    end
  end
end
