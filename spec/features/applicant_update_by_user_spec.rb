require 'rails_helper'

def generate_applicants(n, acceptable = true)
  account = Account.where(subdomain: 'apple').first

  @account_id = account.id
  Account.current_id = @account_id

  grant = Grant.first
  @grant_id = grant.id
  Grant.current_id = @grant_id

  n.times do
    attrs = FactoryGirl.attributes_for(:acceptable_applicant) if acceptable
    attrs = FactoryGirl.attributes_for(:not_acceptable_applicant) unless acceptable
    ApplicantFactory.create(grant, nil, attrs)
  end
end

describe 'applicant' do
  before :each do
    Delayed::Worker.delay_jobs = false
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

    generate_applicants(3)

    #--------applicants created---------

    # an user should be able to assign funding source
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    applicant = Applicant.first
    applicant_id = applicant.id

    ids = Applicant.order(:id).pluck :id
    ap2 = Applicant.find(ids[1]) #second applicant

    nav3_id = User.find_by(email: 'cameron@nomail.net').id
    ap2.navigator_id = nav3_id
    ap2.save

    next_applicant = Applicant.last

    signin_applicants_nav
    visit "/applicants/#{applicant_id}"

    fs_value = find("#applicant_trainee_funding_source_id").value
    expect(fs_value).to be_empty

    select 'HPOG', from: 'applicant_trainee_funding_source_id'
    click_on 'Update'

    expect(page).to have_text next_applicant.email

    signout
  end
end
