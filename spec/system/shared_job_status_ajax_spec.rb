# frozen_string_literal: true
# require 'rails_helper'
# RSpec.configure do |config|
#   config.order = 'defined'
# end
#
# describe 'shared job' do
#   describe 'update status', js: true do
#     before(:each) do
#       allow_any_instance_of(AccountPolicy).to receive(:edit?)
#        .and_return(true)
#       allow_any_instance_of(AccountPolicy).to receive(:update?)
#        .and_return(true)
#
#     end
#     it 'set trainee communication options' do
#       signin_admin
#       visit '/accounts/trainee_options'
#       expect(page).to have_text('Set Trainee Options')
#
#       page.choose('Track status by email')
#
#       click_on 'Update'
#       expect(page).to have_text 'Status (of shared jobs) is tracked'
#
#       signout
#     end
#
#     it 'share jobs with status tracking' do
#       signin_admin
#
#       if ENV['JOB_BOARD'] == 'Indeed'
#         cassette = 'indeed_shared_job_status'
#         count    = 3
#         title1   = 'Draftsperson (Steel Detailer)'
#         title2   = 'machinist'
#       else
#         cassette = 'sh_shared_job_status'
#         count    = 11
#         title1   = 'CNC Machine Operator'
#         title2   = 'CNC Machinist'
#       end
#
#       VCR.use_cassette(cassette) do
#         visit('/job_searches/new')
#         fill_in 'job_search_location', with: 'Edison, NJ'
#         fill_in 'job_search_keywords', with: 'cnc'
#         click_on 'Find'
#
#         expect(page).to have_text "Found: #{count}"
#         expect(page).to have_text title1
#         expect(page).to have_text title2
#
#         hlinks = page.all(:xpath, "//a[contains(@href, '/job_shares/new')]")
#         hlinks[0].click
#         sleep 1
#
#         new_window = windows.last
#
#         Account.current_id = 1
#         Grant.current_id = 1
#         klass = Klass.find(1)
#
#         klass_label = klass.to_label
#
#         page.within_window new_window do
#           # save_and_open_page
#           expect(page).to have_text 'Share Job Information With Trainees'
#           expect(page).to have_text title1
#           select(klass_label, from: 'select_klass')
#           wait_for_ajax
#           select('All', from: 'select_trainees')
#           click_on 'Send'
#           sleep 1
#           wait_for_ajax
#           expect(page).to have_text 'Shared Job Information'
#           expect(page).to have_text title1
#         end
#
#         # it should have created 2 shared_jobs_status records
#         Account.current_id = 1
#         job_share = JobShare.last
#         shared_job = job_share.shared_jobs.first
#         expect(shared_job.title).to match(title1)
#         shared_job_statuses = shared_job.shared_job_statuses
#         shared_job_statuses.each do |shared_job_status|
#           expect(shared_job_status.need_status_feedback?).to eq(true)
#         end
#       end
#       signout
#     end
#
#     it 'simulate trainee click on job lead link to change state to viewed' do
#       Account.current_id = 1
#       job_share = JobShare.last
#       shared_job = job_share.shared_jobs.first
#       shared_job_status = shared_job.shared_job_statuses.last
#
#       # puts job_share.inspect
#       # puts shared_job.inspect
#       # puts shared_job_status.inspect
#
#       expect(shared_job_status.need_status_feedback?).to eq(true)
#
#       id = shared_job_status.id
#       key = shared_job_status.key
#       port = Capybara.server_port
#       url = "/sjs/#{id}?key=#{key}"
#       visit url
#       expect(page).to have_text 'Please click on the job link below, review and '\
#                                 'provide your feedback on this job lead.'
#       sleep 2
#
#       click_link 'Click here to reivew the job details'
#       sleep 2
#
#       Account.current_id = 1
#       shared_job_status = SharedJobStatus.find(id)
#
#       expect(shared_job_status.status).to eq(SharedJobStatus::STATUSES[:VIEWED])
#     end
#
#     it 'click job leadlink and update status and provide feedback' do
#       Account.current_id = 1
#       job_share = JobShare.last
#       shared_job = job_share.shared_jobs.first
#       shared_job_status = shared_job.shared_job_statuses.last
#
#       id = shared_job_status.id
#       key = shared_job_status.key
#       url = "/sjs/#{id}?key=#{key}"
#       visit url
#
#       page.choose 'Applied'
#       fill_in 'Feedback', with: 'Thank You'
#       click_on 'Submit'
#       sleep 2
#
#       Account.current_id = 1
#       shared_job_status = SharedJobStatus.find(id)
#
#       expect(shared_job_status.status).to eq(SharedJobStatus::STATUSES[:APPLIED])
#       expect(shared_job_status.feedback).to eq('Thank You')
#     end
#
#     it 'status on trainee page' do
#       signin_admin
#
#       Account.current_id = 1
#       Grant.current_id = 1
#       job_share = JobShare.last
#       shared_job = job_share.shared_jobs.first
#       shared_job_status = shared_job.shared_job_statuses.last
#       trainee = shared_job_status.trainee
#       trainee_id = trainee.id
#
#       visit "/trainees/#{trainee_id}"
#
#       maximize_window
#       expect(page).to have_selector('td', text: 'Applied')
#
#       signout
#     end
#
#     it 'status on job statuses page' do
#       signin_admin
#
#       Account.current_id = 1
#       Grant.current_id = 1
#       klass = Klass.find(1)
#       klass_label = klass.to_label
#       visit '/sjs' # we used alias - see routes
#       select klass_label, from: 'select_klass'
#       click_on 'Find'
#
#       expect(page).to have_text 'Applied'
#
#       signout
#     end
#   end
# end
