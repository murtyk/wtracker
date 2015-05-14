require 'rails_helper'

def submit_new_applicant_form
  account = Account.where(subdomain: 'apple').first

  @account_id = account.id
  Account.current_id = @account_id

  grant = Grant.first
  @grant_id = grant.id
  Grant.current_id = @grant_id

  salt = "salted#{grant.id}andpeppered"
  visit "/applicants/new?salt=#{salt}"

  @os = build_applicant_data
  @os.address_line1 = '825 Mantoloking Rd'
  @os.address_city  = 'Brick'
  @os.address_zip   = '08723'
  @os.county        = 'Ocean'

  fill_applicant_form(@os)
  click_on 'Submit'
end

describe 'applicant' do
  before :each do
    switch_to_applicants_domain

    allow_any_instance_of(Applicant).to receive(:humanizer_questions)
      .and_return([{ 'question' => 'Two plus two?',
                     'answers' => %w(4 four) }])
  end

  after :each do
    switch_to_main_domain
  end

  it 'can be updated by user' do
    os_latlong = OpenStruct.new(latitude: 40.50, longitude: -75.25)
    allow(GeoServices).to receive(:perform_search).and_return([os_latlong])

    submit_new_applicant_form

    expect(page).to have_text 'We have received your application and a ' \
                              'confirmation email will be sent to you.'

    #--------applicant created---------

    # an user should be able to assign funding source
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    applicant = Applicant.first
    applicant_id = applicant.id

    signin_applicants_admin
    visit "/applicants/#{applicant_id}"

    fs_value = find("#applicant_trainee_funding_source_id").value
    expect(fs_value).to be_empty

    select 'HPOG', from: 'applicant_trainee_funding_source_id'
    click_on 'Update'

    visit "/applicants/#{applicant_id}"
    expect(page).to have_select('applicant_trainee_funding_source_id', selected: 'HPOG')

    signout
  end
end
