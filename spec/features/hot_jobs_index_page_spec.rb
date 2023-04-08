# require 'rails_helper'
# describe 'Hot Jobs' do
#   before :each do
#     Delayed::Worker.delay_jobs = false
#
#     Account.current_id = 1
#     Grant.current_id = 1
#     @employer = Employer.create(name: 'Rspec Company',
#                                 employer_source_id: EmployerSource.first.id)
#
#     @hot_jobs = 2.times.map do
#       FactoryBot.create(:hot_job,
#                          employer_id: @employer.id)
#     end
#
#     @user = admin_user
#     @user_id = @user.id
#     signin_admin
#   end
#   after :each do
#     Account.current_id = 1
#     Grant.current_id = 1
#     @employer.destroy
#     signout
#   end
#   describe 'Index Page' do
#     it 'lists' do
#       visit '/hot_jobs'
#       expect(page).to have_text(@hot_jobs.first.title)
#     end
#     it 'can download' do
#       ENV['MAX_ROWS_FOR_DOWNLOAD'] = '3'
#       visit '/hot_jobs'
#       expect(page).to have_text(@hot_jobs.first.title)
#
#       expect(page).to have_css('.btn-download')
#       find(:xpath, "//a[@href='/hot_jobs.xls']").click
#
#       content_type = page.response_headers['Content-Type']
#
#       expect(content_type).to eql('application/vnd.ms-excel')
#
#       file_name = "hot_jobs_#{@user_id}.xlsx"
#
#       file_path = Rails.root.join('tmp/').to_s + file_name
#       reader = ImportFileReader.new(file_path, file_name)
#
#       titles = []
#       while (row = reader.next_row)
#         titles << row['title']
#       end
#
#       expect(titles.include?(@hot_jobs.first.title)).to be_truthy
#
#       visit '/hot_jobs'
#     end
#   end
# end
