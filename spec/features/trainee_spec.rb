require 'rails_helper'

describe "Trainees" do
    before :each do
      signin_admin
      destroy_all_created
    end
    it 'create' do
      create_trainees(1)
      expect(page).to have_text 'First1 Last1'
    end

    it 'update' do
      trainee_ids = create_trainees(1)
      click_on "edit_trainee_#{trainee_ids[0]}"
      select 'Male',     from: 'trainee_gender'
      fill_in 'Land no', with: '7778882222'
      fill_in 'Dob',     with: '06/07/1992'
      select 'Asian',    from: 'trainee_race_id'
      select 'GED',      from: 'trainee_tact_three_attributes_education_level'
      fill_in 'Email',   with: 'last1@mail.com'

      click_button 'Save'
      expect(page).to have_text 'last1@mail.com'
      expect(page).to have_text '(777) 888-2222'

      expect(page).to_not have_text 'Mercer' # not entered the address yet so no county

      click_on "edit_trainee_#{trainee_ids[0]}"
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

      t1 = Trainee.create(first: 'First1', last: 'Last1', email: 'one@nomail.com')
      t2 = Trainee.create(first: 'First2', last: 'Last2', email: 'two@nomail.com')

      program = Program.first
      college = College.first
      k1 = program.klasses.create(name: 'TestClass1', college_id: college.id)
      k2 = program.klasses.create(name: 'TestClass2', college_id: college.id)

      k1.trainees << t1
      k1.trainees << t2
      k2.trainees << t1
      k2.trainees << t2

      # create_klasses(2, 2)

      href_link('trainees').click
      # klass = get_klasses.first
      klass = k1
      select(klass.name, from: 'filters_klass_id')
      click_button 'Find'

      klass.trainees.each do |trainee|
        expect(page).to have_text trainee.name
      end

      fill_in 'filters_last_name', with: 'last'
      click_button 'Find'
      (1..2).each {|n| expect(page).to have_text "First#{n} Last#{n}"}

    end

    it 'delete', js: true do
      create_trainees(2)
      visit '/trainees'
      fill_in 'filters_last_name', with: 'last'
      click_button 'Find'
      (1..2).each {|n| expect(page).to have_text "First#{n} Last#{n}"}
      get_trainees.each do |trainee|
        click_on "destroy_trainee_#{trainee.id}_link"
        page.driver.browser.switch_to.alert.accept
        wait_for_ajax
      end
      (1..2).each {|n| expect(page).to_not have_text "First#{n} Last#{n}"}
      destroy_all_created
    end
end
