require 'rails_helper'

# RSpec.configure do |config|
#   config.order = "defined"
# end
def fill_in_applicant_fields(employment_status = nil)
  employment_status ||= 'Employed Part Time'

  fill_in 'applicant_first_name',      with: 'Adaline'
  fill_in 'applicant_last_name',       with: 'Schuster'
  fill_in 'applicant_address_line1',   with: '120 Wood Ave S'
  fill_in 'applicant_address_city',    with: 'Iselin'
  fill_in 'applicant_address_zip',     with: '08830'
  select  'Middlesex',                 from: 'applicant_county_id'
  fill_in 'applicant_email',           with: 'adaline_schuster@shields.biz'
  fill_in 'applicant_mobile_phone_no', with: '626 656 2323'
  select 'telecom',                    from: 'applicant_sector_id'

  select 'No',                         from: 'applicant_veteran'
  select 'Resident Alien',             from: 'applicant_legal_status'
  select 'Male',                       from: 'applicant_gender'
  select 'Asian',                      from: 'applicant_race_id'

  select employment_status,            from: 'applicant_current_employment_status'

  fill_in 'applicant_last_employed_on',    with: '10/17/2014'
  fill_in 'applicant_last_employer_name',  with: 'ABC Inc'
  fill_in 'applicant_last_employer_line1', with: '1 Metroplex Dr'
  fill_in 'applicant_last_employer_city',  with: 'Edison'
  select  'NJ',                            from: 'applicant_last_employer_state'
  fill_in 'applicant_last_employer_zip',   with: '08817'

  fill_in 'applicant_last_employer_manager_name',      with: 'John Smith'
  fill_in 'applicant_last_employer_manager_phone_no',  with: '7773332222'

  fill_in 'applicant_last_wages',         with: '100K'
  fill_in 'applicant_last_job_title',     with: 'Sr. Developer'
  fill_in 'applicant_salary_expected',    with: '75-85K'
  select 'GED',                           from: 'applicant_education_level'
  select 'Letter from Unemployment',      from: 'applicant_unemployment_proof'
  select 'Child Care',                    from: 'applicant[special_service_ids][]'
  select 'Yes',                           from: 'applicant_transportation'
  select 'No',                            from: 'applicant_computer_access'

  select 'One Stop',                      from: 'applicant_source'

  # use the below when ready to test js: true
  # select 'Other, please specify',             from: 'applicant_reference'
  # prompt = page.driver.browser.switch_to.alert
  # prompt.send_keys('This is my reference')
  # prompt.accept

  fill_in 'applicant_resume',  with: 'I am an excellent software developer with 10 years' \
                                     ' of experience in java, ajax, xml, oracle'
  fill_in 'applicant_humanizer_answer', with: '4'

  check 'applicant_signature'
end
def visit_new_applicant_page
    account = Account.where(subdomain: 'apple').first
    Account.current_id = account.id
    grant = Grant.first
    Grant.current_id = grant.id

    salt = "salted#{grant.id}andpeppered"
    visit "/applicants/new?salt=#{salt}"
end

describe "applicants" do

  before :each do
    switch_to_applicants_domain

    @filepath = "#{Rails.root}/spec/fixtures/RESUME.docx"
    allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
    allow(Amazon).to receive(:file_url).and_return(@filepath)

    allow_any_instance_of(Applicant).to receive(:humanizer_questions)
                                        .and_return([{"question"=>"Two plus two?",
                                                      "answers"=>["4", "four"]}])
  end

  after :each do
    switch_to_main_domain
  end

  it 'accepts applicant and creates trainee' do
    VCR.use_cassette('applicant') do
      visit_new_applicant_page
      fill_in_applicant_fields
      click_on 'Submit'

      expect(page).to have_text 'We have received your application and a confirmation email will be sent to you.'

      applicant = Applicant.unscoped.first
      expect(applicant.name).to eq('Adaline Schuster')
      expect(applicant.status).to eq('Accepted')
      trainee = Trainee.unscoped.find(applicant.trainee_id)
      expect(trainee.name).to eq('Adaline Schuster')

      trainee_id = trainee.id

      signin_applicants_admin
      visit "/trainees/#{trainee_id}"
      click_on 'Go To Applicant Page'

      expect(page).to have_text('Adaline Schuster')
      expect(page).to have_text('(626) 656-2323')
      expect(page).to have_text('Middlesex')
      expect(page).to have_text('telecom')

      select 'banking', from: 'applicant_sector_id'
      click_on 'Update'
      expect(page).to have_text('Applicant updated successfully')

      visit '/applicants/analysis'

      nav_id = User.unscoped.where(email: 'melinda1@mail.com').first.id
      method = 'navigator_new_applicants'
      href   = applicants_path(query: { method: method, navigator_id: nav_id })
      expect(page).to have_link '1', href: href

      visit href
      expect(page).to have_text('Adaline Schuster')
      expect(page).to have_text('Middlesex')
      expect(page).to have_text('banking')

      signout
    end
  end

  it 'declines applicant and does not create trainee' do
    VCR.use_cassette('applicant') do
      visit_new_applicant_page
      fill_in_applicant_fields('Employed Full Time')
      click_on 'Submit'

      expect(page).to have_text 'We have received your application and a confirmation email will be sent to you.'

      applicant = Applicant.unscoped.first
      expect(applicant.name).to eq('Adaline Schuster')
      expect(applicant.status).to eq('Declined')

      expect(applicant.trainee_id).to be_nil
    end
  end

  it 'trainee can sign in and provide information' do
    VCR.use_cassette('applicant') do
      visit_new_applicant_page
      fill_in_applicant_fields
      click_on 'Submit'

      switch_to_applicants_domain
      visit '/trainees/sign_in'

      fill_in 'trainee_login_id',     with: 'Adaline_Schuster'
      fill_in 'password',  with: 'adaline_schuster'
      click_button 'Sign in'

      expect(page).to have_text('Date of Birth')
      fill_in 'trainee_trainee_id', with: '123456789'
      fill_in 'trainee_dob', with: "12/28/1990"
      click_on 'Next'
      expect(page).to have_text('Please enter your preferences for job leads')

      fill_in 'job_search_profile_skills',    with: 'java, ajax, xml'
      fill_in 'job_search_profile_location',  with: 'Edison,NJ'
      fill_in 'job_search_profile_distance',  with: '20'

      click_on 'Update'
      expect(page).to have_text 'resume'

      attach_file "trainee_file_file", @filepath

      click_on 'Submit'
      expect(page).to have_text 'Suggested Job Posts'

      # AutoJobLeads.new.perform
      # click_on 'Jobs'
      # expect(page).to have_text 'Suggested Job Posts'

      # spec trainee placements
      click_on 'Got A Job?'
      fill_in 'trainee_placement_company_name',  with: 'ABCDEF Inc'
      fill_in 'trainee_placement_address_line1', with: '1 Metroplex Drive'
      fill_in 'trainee_placement_city',          with: 'Edison'
      fill_in 'trainee_placement_zip',           with: '08817'
      fill_in 'trainee_placement_phone_no',      with: '4443332222'
      fill_in 'trainee_placement_salary',        with: '33333'
      fill_in 'trainee_placement_job_title',     with: 'Analyst'
      fill_in 'trainee_placement_start_date',    with: '12/31/2015'

      select 'NJ', from: 'trainee_placement_state'

      click_on 'Add'

      click_on 'Placements'
      expect(page).to have_text 'ABCDEF Inc'
    end
  end
end