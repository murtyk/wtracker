# require 'rails_helper'
# 
# def salt
#   account = Account.where(subdomain: 'apple').first
#   Account.current_id = account.id
#   grant = Grant.first
#   Grant.current_id = grant.id
# 
#   "salted#{grant.id}andpeppered"
# end
# 
# def visit_new_applicant_page
#   visit "/applicants/new?salt=#{salt}"
# end
# 
# def visit_applicant_reapply_page
#   visit "/applicant_reapplies/new?salt=#{salt}"
# end
# 
# def visit_reapply_form_for(email)
#   grant_salt = salt # call this first for setting current_ids
#   applicant  = Applicant.where('email ilike ?', email).first
#   id = applicant.id
#   key = applicant.reapply_key
#   visit "/applicants/#{id}/edit?salt=#{grant_salt}&key=#{key}"
# end
# 
# describe 'applicant re-apply' do
#   before :each do
#     Delayed::Worker.delay_jobs = false
#     switch_to_applicants_domain
#     allow_any_instance_of(Applicant).to receive(:humanizer_questions)
#       .and_return([{ 'question' => 'Two plus two?',
#                      'answers' => %w(4 four) }])
# 
#     @instructions = 'Not found. Please enter correct email address.'
#     allow_any_instance_of(Grant).to receive(:reapply_instructions)
#       .and_return(@instructions)
#   end
# 
#   after :each do
#     switch_to_main_domain
#   end
# 
#   it 'does not acceept invalid email' do
#     msg = 'Not found. Please enter correct email address.'
#     allow_any_instance_of(Grant).to receive(:reapply_email_not_found_message)
#       .and_return(msg)
#     visit_applicant_reapply_page
#     expect(page).to have_text @instructions
#     fill_in 'applicant_reapply_email', with: 'bad@noemail.ddd'
#     click_on 'Submit'
#     expect(page).to have_text msg
#   end
# 
#   it 'does not allow re-apply for accepted applicant' do
#     msg = 'You are already accepted and should have received an e-mail.'
#     allow_any_instance_of(Grant).to receive(:reapply_already_accepted_message)
#       .and_return(msg)
# 
#     os = OpenStruct.new(accepted?: true)
#     allow(Applicant).to receive(:find_by).and_return(os)
# 
#     visit_applicant_reapply_page
#     fill_in 'applicant_reapply_email', with: 'name@noemail.ddd'
#     click_on 'Submit'
#     expect(page).to have_text msg
#   end
# 
#   it 'declines applicant and allows re-apply' do
#     msg = 'We sent you instructions for reapplying. Please check your email.'
#     allow_any_instance_of(Grant).to receive(:reapply_confirmation_message)
#       .and_return(msg)
# 
#     allow_any_instance_of(Grant).to receive(:reapply_subject)
#       .and_return('Reapply instructions')
# 
#     allow_any_instance_of(Grant).to receive(:reapply_body)
#       .and_return('$FIRSTNAME$, $LASTNAME$, <br> $REAPPLY_LINK$')
# 
#     VCR.use_cassette('applicant') do
#       # for apply and get declined
#       visit_new_applicant_page
# 
#       os_applicant =  build_applicant_data(false)
#       fill_applicant_form(os_applicant)
#       click_on 'Submit'
# 
#       expect(page).to have_text 'We have received your application and a ' \
#                                 'confirmation email will be sent to you.'
# 
#       applicant = Applicant.unscoped.first
#       expect(applicant.name).to eq(os_applicant.name)
#       expect(applicant.status).to eq('Declined')
# 
#       expect(applicant.trainee_id).to be_nil
# 
#       # now reapply
# 
#       visit_applicant_reapply_page
#       fill_in 'applicant_reapply_email', with: os_applicant.email
#       click_on 'Submit'
# 
#       expect(page).to have_text msg
# 
#       mail = ActionMailer::Base.deliveries.last
#       expect(mail.subject).to eq('Reapply instructions')
# 
#       # applicant clicks link in email
# 
#       visit_reapply_form_for(os_applicant.email)
# 
#       select 'Employed Part Time',  from: 'applicant_current_employment_status'
# 
#       click_on 'Submit'
# 
#       expect(page).to have_text 'We have received your application and a '\
#                                 'confirmation email will be sent to you.'
# 
#       applicant = Applicant.unscoped.first
#       expect(applicant.name).to eq(os_applicant.name)
#       expect(applicant.status).to eq('Accepted')
#       trainee = Trainee.unscoped.find(applicant.trainee_id)
#       expect(trainee.name).to eq(os_applicant.name)
#     end
#   end
# end
