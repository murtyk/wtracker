require 'rails_helper'

describe 'Job Search' do
  describe 'ajax in new search' do
    before :each do
      signin_admin
    end
    after :each do
      signout
    end

    it 'searches for jobs and shares them', js: true do
      visit('/job_searches/new')
      maximize_window
      if ENV['JOB_BOARD'] == 'Indeed'
        cassette = 'indeed_job_search_and_analyze'
        keywords = 'Java XML'
        count    = 86
        pages    = 4
        title    = 'Senior Java Developer - Team Lead'
        company  = 'Accenture'
      else
        cassette = 'sh_job_search_and_analyze'
        keywords = 'pediatric nurse'
        count    = 104
        pages    = 5
        title    = 'RN CLINICAL Special Care'
        company  = 'Bayada'
      end
      VCR.use_cassette(cassette) do
        select('5', from: 'job_search_distance')
        fill_in 'job_search_location', with: 'Camden, NJ'
        fill_in 'job_search_keywords', with: keywords
        click_on 'Find'

        expect(page).to have_text "Found: #{count}"
        expect(page).to have_text "Page 1 of #{pages}"
        expect(page).to have_text title

        click_on 'Analyze'

        wait_for_ajax
        sleep 8
        wait_for_ajax

        maximize_window
        expect(page).to have_text "Total Jobs Found: #{count}"
        expect(page).to have_text company

        select('health', from: 'sector_ids')
        first(:link, 'Add').click
        wait_for_ajax
        expect(page).to have_text 'Saved'

        btn_id = first(:xpath, "//*[contains(@id, 'sharejobs')]")[:id]
        # save_screenshot('c:/temp/jobsearch')
        click_on btn_id

        # session.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
        new_window = page.driver.browser.window_handles.last

        Account.current_id = 1
        Grant.current_id = 1
        klass = Klass.find(1)

        klass_label = klass.to_label

        page.within_window new_window do
          # save_and_open_page
          select(klass_label, from: 'select_klass')
          wait_for_ajax
          select('All', from: 'select_trainees')
          sleep 1
          click_on 'Send'
          wait_for_ajax
          sleep 1
          expect(page).to have_text 'Shared Job Information'
        end
      end
    end
  end
end
