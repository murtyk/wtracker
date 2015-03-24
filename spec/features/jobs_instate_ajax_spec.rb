require 'rails_helper'

describe "Job Search" do
  describe 'new search' do

    before :each do
    	signin_admin
    end

    after :each do
      signout
    end

    it 'searches for in state jobs and shares them', js: true, retry: 2, retry_wait: 3 do
    	visit('/job_searches/new')
    	sleep 1
      maximize_window

      if ENV['JOB_BOARD'] == 'Indeed'
        cassette = 'indeed_job_search_in_state'
        count    = 17
        title1   = 'Registered Nurse'
        title2   = 'Pediatric Nurse'
        company1 = 'Genesis HealthCare'
        company2 = 'CAMCare Health'
      else
        cassette = 'sh_job_search_in_state'
        count    = 9
        title1   = "RN / LPN"
        title2   = "Pediatric Home Care Nurse"
        company1 = "Bayada Home Health Care"
        company2 = "Kennedy Health System"
      end

  		VCR.use_cassette(cassette) do
        select('5', from: 'job_search_distance')
        fill_in 'job_search_location', with: 'Camden, NJ'
        fill_in 'job_search_keywords', with: 'pediatric nurse'
        check('job_search_in_state')
        click_on 'Find'

        wait_for_ajax

        expect(page).to have_text "Found: #{count}"
        expect(page).to have_text title1
        expect(page).to have_text company1

        sleep 1

        click_on 'Analyze'

        wait_for_ajax
        sleep 5
        wait_for_ajax

        expect(page).to have_text "Total Jobs Found: #{count}"
        expect(page).to have_text company2

        select('health', from: 'sector_ids')
        first(:link, 'Add').click
        wait_for_ajax
        expect(page).to have_text "Saved"

        # check ('Nurses for Pediatric Home Care Cherry Hill RN LPN')
        sleep 2
        btn_id = first(:xpath, "//*[contains(@id, 'sharejobs')]")[:id]
        # 	# save_screenshot('c:/temp/jobsearch')
        click_on btn_id
        sleep 2


        # session.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
        new_window=page.driver.browser.window_handles.last

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
          sleep 5
          expect(page).to have_text "Shared Job Information"
        end

        visit('/job_shares')
        select(klass_label, from: 'select_klass')
        click_on 'Find'
        sleep 0.5
        expect(page).to have_text title2

      end

    end
  end
end