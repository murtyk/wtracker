require 'rails_helper'
RSpec.configure do |config|
  config.order = "defined"
end

describe "shared job" do

  describe "update status" do
    before(:each) do
      signin_admin
    end
    it "set trainee communication options", js: true do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit '/accounts/trainee_options'
      expect(page).to have_text('Set Trainee Options')
      # expect(page).to have_text('Current Setting: Status (of shared jobs) is NOT tracked')

      page.choose('Track status by email')

      click_on 'Update'
      expect(page).to have_text 'Status (of shared jobs) is tracked'

    end

    it "share jobs with status tracking", js: true do

      if ENV['JOB_BOARD'] == 'Indeed'
        cassette = 'indeed_shared_job_status'
        count    = 2
        title1   = 'ASST INSTRMNT MAKER'
        title2   = 'Warehouse Maintenance Manager'
      else
        cassette = 'sh_shared_job_status'
        count    = 9
        title1   = 'CNC Machine Operator'
        title2   = 'CNC MOLDER'
      end

      VCR.use_cassette(cassette) do
        visit('/job_searches/new')
        fill_in 'job_search_location', with: 'Edison, NJ'
        fill_in 'job_search_keywords', with: 'cnc'
        click_on 'Find'

        expect(page).to have_text "Found: #{count}"
        expect(page).to have_text title1
        expect(page).to have_text title2

        hlinks = page.all(:xpath, "//a[contains(@href, '/job_shares/new')]")
        hlinks[0].click
        sleep 1

        prev_window=page.driver.browser.window_handles.first
        new_window=page.driver.browser.window_handles.last
        Account.current_id = 1
        Grant.current_id = 1
        klass = Klass.find(1)

        klass_label = klass.to_label

        page.within_window new_window do
          # save_and_open_page
          expect(page).to have_text "Share Job Information With Trainees"
          expect(page).to have_text title1
          select(klass_label, from: 'select_klass')
          wait_for_ajax
          select('All', from: 'select_trainees')
          click_on 'Send'
          sleep 1
          wait_for_ajax
          expect(page).to have_text "Shared Job Information"
          expect(page).to have_text title1
        end

        # it should have created 2 shared_jobs_status records
        Account.current_id = 1
        job_share = JobShare.last
        shared_job = job_share.shared_jobs.first
        expect(shared_job.title).to  match(title1)
        shared_job_statuses = shared_job.shared_job_statuses
        shared_job_statuses.each do |shared_job_status|
          expect(shared_job_status.need_status_feedback?).to eq(true)
        end
      end
    end

    it "simulate trainee click on job lead link to change state to viewed", js: true do
      Account.current_id = 1
      job_share = JobShare.last
      shared_job = job_share.shared_jobs.first
      shared_job_status = shared_job.shared_job_statuses.last

      # puts job_share.inspect
      # puts shared_job.inspect
      # puts shared_job_status.inspect

      expect(shared_job_status.need_status_feedback?).to eq(true)

      id = shared_job_status.id
      key = shared_job_status.key
      port = Capybara.server_port
      url = "http://www.localhost.com:#{port}/sjs/#{id}?key=#{key}"
      visit url
      expect(page).to have_text "Please click on the job link below, review and provide your feedback on this job lead."
      sleep 2

      click_link 'Click here to reivew the job details'
      sleep 2

      Account.current_id = 1
      shared_job_status = SharedJobStatus.find(id)

      expect(shared_job_status.status).to eq(SharedJobStatus::STATUSES[:VIEWED])

    end

    it "click job leadlink and update status and provide feedback", js: true do

      Account.current_id = 1
      job_share = JobShare.last
      shared_job = job_share.shared_jobs.first
      shared_job_status = shared_job.shared_job_statuses.last

      id = shared_job_status.id
      key = shared_job_status.key
      url = "http://www.localhost.com:7171/sjs/#{id}?key=#{key}"
      visit url

      page.choose 'Applied'
      fill_in 'Feedback', with: 'Thank You'
      click_on 'Submit'
      sleep 2

      Account.current_id = 1
      shared_job_status = SharedJobStatus.find(id)

      expect(shared_job_status.status).to eq(SharedJobStatus::STATUSES[:APPLIED])
      expect(shared_job_status.feedback).to eq('Thank You')

    end

    it "status on trainee page" do
      Account.current_id = 1
      Grant.current_id = 1
      job_share = JobShare.last
      shared_job = job_share.shared_jobs.first
      shared_job_status = shared_job.shared_job_statuses.last
      trainee = shared_job_status.trainee
      trainee_id = trainee.id

      visit "/trainees/#{trainee_id}"

      expect(page).to have_selector("td", text: "Applied")

    end

    it 'status on job statuses page' do
      Account.current_id = 1
      Grant.current_id = 1
      klass = Klass.find(1)
      klass_label = klass.to_label
      visit '/sjs' #we used alias - see routes
      select klass_label, from: 'select_klass'
      click_on 'Find'
      expect(page).to have_text 'Applied'
    end

  end
end