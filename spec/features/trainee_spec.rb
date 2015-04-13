require 'rails_helper'

describe 'Trainees' do
  before :each do
    signin_admin
    Account.current_id = 1
    Grant.current_id = 1
    klass = Klass.first
    @klass_label = klass.to_label
  end
  it 'create' do
    visit '/trainees/new'
    fill_in 'First Name', with: 'First1000'
    fill_in 'Last Name', with: 'Last1000'
    fill_in 'Email', with: 'Last2000@nomail.net'
    select(@klass_label, from: 'trainee_klass_ids')
    click_button 'Save'
    expect(page).to have_text 'First1000 Last1000'
  end

  it 'update' do
    trainee = Trainee.create(first: 'First2000', last: 'Last2000')

    trainee_id = trainee.id

    visit "/trainees/#{trainee_id}"
    click_on "edit_trainee_#{trainee_id}"
    select 'Male',     from: 'trainee_gender'
    fill_in 'Land no', with: '7778882222'
    fill_in 'Dob',     with: '06/07/1992'
    select 'Asian',    from: 'trainee_race_id'
    select 'GED',      from: 'trainee_tact_three_attributes_education_level'
    fill_in 'Email',   with: 'last2000@nomail.net'

    click_button 'Save'
    expect(page).to have_text 'last2000@nomail.net'
    expect(page).to have_text '(777) 888-2222'

    expect(page).to_not have_text 'Mercer' # not entered the address yet so no county

    click_on "edit_trainee_#{trainee_id}"
    VCR.use_cassette('trainee_update') do
      fill_in 'trainee_home_address_attributes_line1', with: '10 Rembrandt'
      fill_in 'trainee_home_address_attributes_city', with: 'East Windsor'
      select 'NJ', from: 'trainee_home_address_attributes_state'
      fill_in 'trainee_home_address_attributes_zip', with: '08520'

      click_button 'Save'
    end

    expect(page).to have_text 'Mercer'
  end

  it 'searches' do
    Account.current_id = 1
    Grant.current_id = 1

    t1 = Trainee.create(first: 'First51', last: 'Last51', email: 'one@nomail.com')
    t2 = Trainee.create(first: 'First52', last: 'Last52', email: 'two@nomail.com')

    program = Program.first
    college = College.first
    k1 = program.klasses.create(name: 'TestClass1', college_id: college.id)
    k2 = program.klasses.create(name: 'TestClass2', college_id: college.id)

    k1.trainees << t1
    k1.trainees << t2
    k2.trainees << t1
    k2.trainees << t2

    href_link('trainees').click

    klass = k1
    select(klass.name, from: 'filters_klass_id')
    click_button 'Find'

    klass.trainees.each do |trainee|
      expect(page).to have_text trainee.name
    end

    fill_in 'filters_last_name', with: 'last'
    click_button 'Find'
    (1..2).each { |n| expect(page).to have_text "First#{50 + n} Last#{50 + n}" }
  end
end
describe 'Trainees' do
  before :each do
    signin_admin
  end

  it 'delete', js: true do
    create_trainees(2, nil, 3000)
    visit '/trainees'
    fill_in 'filters_last_name', with: 'last'
    click_button 'Find'
    (1..2).each { |n| expect(page).to have_text "First#{3000 + n} Last#{3000 + n}" }
    get_trainees.each do |trainee|
      click_on "destroy_trainee_#{trainee.id}_link"
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
    end
    (1..2).each { |n| expect(page).to_not have_text "First#{3000 + n} Last#{3000 + n}" }
  end
end
