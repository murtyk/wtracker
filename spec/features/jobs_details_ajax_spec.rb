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
        count    = 16
        title1   = 'Business Systems Analyst with Strong Java background'
        details  = 'IRIS Software'
      end

      VCR.use_cassette(cassette) do
        fill_in 'job_search_location', with: 'Princeton,NJ'
        fill_in 'job_search_keywords', with: 'Java Ajax'
        click_on 'Find'

        expect(page).to have_text "Found: #{count}"

        click_on title1

        page.within_window(windows.last) do

          10.times do
            break if page.html.index(details)
            sleep 0.5
          end

          expect(page.html.index(details) != nil).to be_truthy
        end
      end
    end
  end
end
