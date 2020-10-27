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
        count    = 83
        pages    = 4
        title    = 'Java Hadoop Developer'
        company  = 'Diverse Lynx'
      else
        cassette = 'sh_job_search_and_analyze'
        keywords = 'pediatric nurse RN'
        count    = 42
        pages    = 2
        title    = 'Registered Nurse'
        company  = 'Kennedy Health System'
      end
      VCR.use_cassette(cassette, record: :none) do
        select('5', from: 'job_search_distance')
        fill_in 'job_search_location', with: 'Camden, NJ'
        fill_in 'job_search_keywords', with: keywords
        click_on 'Find'

        expect(page).to have_text "Found: #{count}"
        expect(page).to have_text "Page 1 of #{pages}"
        expect(page).to have_text title

        # TODO: vcr cassette does not have google stuff. we need to rerecord.

        # click_on 'Analyze'

        # wait_for_ajax
        # sleep 8
        # wait_for_ajax

        # maximize_window
        # expect(page).to have_text "Total Jobs Found: #{count}"
        # expect(page).to have_text company

        # select('health', from: 'sector_ids')
        # first(:link, 'Add').click
        # wait_for_ajax
        # expect(page).to have_text 'Saved'

        # btn_id = first(:xpath, "//*[contains(@id, 'sharejobs')]")[:id]
        # # save_screenshot('c:/temp/jobsearch')
        # click_on btn_id

        # # session.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
        # new_window = windows.last

        # Account.current_id = 1
        # Grant.current_id = 1
        # klass = Klass.find(1)

        # klass_label = klass.to_label

        # page.within_window new_window do
        #   # save_and_open_page

        #   select(klass_label, from: 'select_klass_gmap')
        #   wait_for_ajax
        #   select('All', from: 'select_trainees')
        #   sleep 1
        #   click_on 'Send'
        #   # wait_for_ajax
        #   # 20.times do
        #   #   break if page.html.index('Shared Job Information')
        #   #   sleep 0.5
        #   # end

        #   # expect(!page.html.index('Shared Job Information').nil?).to be_truthy
        # end
      end
    end
  end
end
