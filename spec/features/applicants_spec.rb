require 'rails_helper'

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

  it 'reports errors when trainee can not be created' do
    allow(TraineeFactory).to receive(:create_trainee_from_applicant)
                             .and_return(Trainee.create)
    visit_new_applicant_page

    fill_applicant_form(build_applicant_data)

    click_on 'Submit'

    expect(page).to have_text("can't be blank")
  end

  it 'accepts applicant and creates trainee with default grant_trainee_status' do
    VCR.use_cassette('applicant') do
      visit_new_applicant_page
      os_applicant = build_applicant_data
      fill_applicant_form(os_applicant)
      click_on 'Submit'

      expect(page).to have_text 'We have received your application and a confirmation email will be sent to you.'

      applicant = Applicant.unscoped.first
      Account.current_id = applicant.account_id
      Grant.current_id = applicant.grant_id
      trainee = Trainee.find(applicant.trainee_id)
      trainee_id = trainee.id
      ts = TraineeStatus.where(trainee_id: trainee_id).first
      ts_name = ts.name
      ts_display = "#{ts.created_at.to_date.to_s} - #{ts.name}"


      expect(applicant.name).to eq(os_applicant.name)
      expect(applicant.status).to eq('Accepted')
      expect(trainee.name).to eq(os_applicant.name)
      expect(ts_name).to eql('Active')

      signin_applicants_admin
      visit "/trainees/#{trainee_id}"
      expect(page).to have_text(ts_display)
      click_on 'Go To Applicant Page'

      expect(page).to have_text(os_applicant.name)
      expect(page).to have_text('(626) 656-2323')
      expect(page).to have_text(os_applicant.county)
      expect(page).to have_text(os_applicant.sector)

      select 'banking', from: 'applicant_sector_id'
      click_on 'Update'
      expect(page).to have_text('Applicant updated successfully')

      visit '/applicants/analysis'

      nav_id = User.unscoped.where(email: 'melinda1@mail.com').first.id
      method = 'navigator_new_applicants'
      href   = applicants_path(query: { method: method, navigator_id: nav_id })
      expect(page).to have_link '1', href: href

      visit href
      expect(page).to have_text(os_applicant.name)
      expect(page).to have_text(os_applicant.county)
      expect(page).to have_text('banking')

      signout
    end
  end

  it 'declines applicant and does not create trainee' do
    VCR.use_cassette('applicant') do
      visit_new_applicant_page
      os_applicant = build_applicant_data(false)
      fill_applicant_form(os_applicant)
      click_on 'Submit'

      expect(page).to have_text 'We have received your application and a confirmation email will be sent to you.'

      applicant = Applicant.unscoped.first
      expect(applicant.name).to eq(os_applicant.name)
      expect(applicant.status).to eq('Declined')

      expect(applicant.trainee_id).to be_nil
    end
  end

  it 'trainee can sign in and provide information' do
    VCR.use_cassette('applicant') do
      visit_new_applicant_page
      fill_applicant_form(build_applicant_data)
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