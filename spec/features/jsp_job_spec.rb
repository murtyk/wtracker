# require 'rails_helper'
# 
# def submit_new_applicant_form
#   account = Account.where(subdomain: 'apple').first
# 
#   @account_id = account.id
#   Account.current_id = @account_id
# 
#   grant = Grant.first
#   grant.unemployment_proof_text = "$EMPLOYMENT_STATUS$"
# 
#   grant.email_password_subject = "Here is your password"
#   grant.email_password_body = "Hello $FIRST_NAME$, password is $PASSWORD$"
# 
#   grant.save
# 
# 
#   @grant_id = grant.id
#   Grant.current_id = @grant_id
# 
#   salt = "salted#{grant.id}andpeppered"
#   visit "/applicants/new?salt=#{salt}"
# 
#   @os = build_applicant_data
#   @os.address_line1 = '825 Mantoloking Rd'
#   @os.address_city  = 'Brick'
#   @os.address_zip   = '08723'
#   @os.county        = 'Ocean'
# 
#   fill_applicant_form(@os)
#   click_on 'Submit'
# end
# 
# describe 'job search profile job' do
#   before :each do
#     Delayed::Worker.delay_jobs = false
#     switch_to_applicants_domain
# 
#     allow_any_instance_of(Applicant).to receive(:humanizer_questions)
#       .and_return([{ 'question' => 'Two plus two?',
#                      'answers' => %w(4 four) }])
#   end
# 
#   after :each do
#     switch_to_main_domain
#   end
# 
#   it 'accepts applicant and creates trainee' do
#     allow(GeoServices).to receive(:perform_search).and_return([])
# 
#     submit_new_applicant_form
# 
#     expect(page).to have_text 'We have received your application and a ' \
#                               'confirmation email will be sent to you.'
# 
#     #--------applicant created---------
# 
#     #   trainee address should be missing and jsp will have null values
#     Account.current_id = @account_id
#     Grant.current_id = @grant_id
#     applicant = Applicant.first
# 
#     trainee = applicant.trainee
# 
#     expect(trainee.home_address).to be_nil
# 
#     jsp = trainee.job_search_profile
#     expect(jsp.skills).to be_nil
# 
#     os_latlong = OpenStruct.new(latitude: 40.50, longitude: -75.25)
#     allow(GeoServices).to receive(:perform_search).and_return([os_latlong])
# 
#     # job should create home address and fill in jsp with good values
#     JobSearchProfileJob.new.perform
# 
#     Account.current_id = @account_id
#     Grant.current_id = @grant_id
#     applicant = Applicant.first
# 
#     trainee = applicant.trainee
# 
#     expect(trainee.home_address).not_to be_nil
#     jsp = trainee.job_search_profile
#     expect(jsp.skills).not_to be_nil
# 
#     # lets delete home address and make jps values null. job should fix both.
#     trainee.job_search_profile.destroy
#     trainee.home_address.destroy
# 
#     JobSearchProfileJob.new.perform
# 
#     Account.current_id = @account_id
#     Grant.current_id = @grant_id
#     applicant = Applicant.first
# 
#     trainee = applicant.trainee
# 
#     expect(trainee.home_address).not_to be_nil
#     jsp = trainee.job_search_profile
#     expect(jsp.skills).not_to be_nil
#   end
# end
