require 'rails_helper'

describe 'Job Search' do
  describe 'details' do
    before :each do
      signin_admin
    end
    after :each do
      signout
    end

    it 'searches for jobs and shows details', js: true, retry: 1, retry_wait: 3 do
      visit('/job_searches/new')
      sleep 1
      maximize_window
      if ENV['JOB_BOARD'] == 'Indeed'
        cassette = 'indeed_job_details'
        count    = 45
        title1   = 'Java caching developer'
        details  = 'Princeton'
      else
        cassette = 'sh_job_details'
        count    = 15
        title1   = 'Java Developer - Level: Officer or AVP level - Large US Bank'
        details  = 'Konnect Partners'
      end

      VCR.use_cassette(cassette) do
        fill_in 'job_search_location', with: 'Princeton,NJ'
        fill_in 'job_search_keywords', with: 'Java Ajax'
        click_on 'Find'

        expect(page).to have_text "Found: #{count}"

        click_on title1
        prev_window = page.driver.browser.window_handles.first

        new_window = page.driver.browser.window_handles.last
        page.driver.browser.switch_to.window(new_window)

        expect(page).to have_text details

        page.driver.browser.switch_to.window(prev_window)
      end
    end
  end
end
