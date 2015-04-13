require 'rails_helper'

describe 'Trainees' do
  describe 'create for a college account' do
    before :each do
      signin_college_admin
    end
    it 'can create trainee' do
      href_link('trainees').click
      click_button 'Find'

      VCR.use_cassette('trainee_create') do
        href_link('trainees/new').click

        fill_in 'First Name', with: 'Karen'
        fill_in 'Last Name', with: 'Singer'
        fill_in 'Email',      with: 'singer@mail.com'
        fill_in 'Trainee ID', with: 'BD11110000'
        select('HPOG', from: 'Funding source')

        fill_in 'trainee_home_address_attributes_line1', with: '10 Rembrandt'
        fill_in 'trainee_home_address_attributes_city', with: 'East Windsor'
        select 'NJ', from: 'trainee_home_address_attributes_state'
        fill_in 'trainee_home_address_attributes_zip', with: '08520'

        select('Male', from: 'trainee_gender')

        fill_in 'Land no', with: '7778882222'
        fill_in 'Dob', with: '06/07/1980'

        select('GED', from: 'trainee_tact_three_attributes_education_level')

        Account.current_id = Account.where(subdomain: 'brookdale').first.id
        Grant.current_id = Grant.first.id
        select(Klass.first.to_label, from: 'trainee_klass_ids')

        click_button 'Save'
        expect(page).to have_text 'Karen Singer'
        expect(page).to have_text 'HPOG'
        signout
      end
    end
  end
end
