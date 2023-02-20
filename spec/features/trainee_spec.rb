# require 'rails_helper'
# 
# describe 'Trainees' do
#   before :each do
#     signin_admin
#     Account.current_id = 1
#     Grant.current_id = 1
#     klass = Klass.first
#     @klass_label = klass.to_label
#   end
#   it 'create' do
#     visit '/trainees/new'
#     fill_in 'First Name', with: 'First1000'
#     fill_in 'Last Name', with: 'Last1000'
#     fill_in 'Email', with: 'Last2000@nomail.net'
#     select(@klass_label, from: 'trainee_klass_ids')
#     click_button 'Save'
#     expect(page).to have_text 'First1000 Last1000'
#   end
# 
#   it 'update' do
#     trainee = Trainee.create(first: 'First2000', last: 'Last2000')
# 
#     trainee_id = trainee.id
# 
#     visit "/trainees/#{trainee_id}"
#     click_on "edit_trainee_#{trainee_id}"
#     select 'Male',     from: 'trainee_gender'
#     fill_in 'Land no', with: '7778882222'
#     fill_in 'Dob',     with: '06/07/1992'
#     select 'Asian',    from: 'trainee_race_id'
#     select 'GED',      from: 'trainee_tact_three_attributes_education_level'
#     fill_in 'Email',   with: 'last2000@nomail.net'
# 
#     click_button 'Save'
#     expect(page).to have_text 'last2000@nomail.net'
#     expect(page).to have_text '(777) 888-2222'
# 
#     expect(page).to_not have_text 'Mercer' # not entered the address yet so no county
# 
#     click_on "edit_trainee_#{trainee_id}"
#     VCR.use_cassette('trainee_update') do
#       fill_in 'trainee_home_address_attributes_line1', with: '10 Rembrandt'
#       fill_in 'trainee_home_address_attributes_city', with: 'East Windsor'
#       select 'NJ', from: 'trainee_home_address_attributes_state'
#       fill_in 'trainee_home_address_attributes_zip', with: '08520'
# 
#       click_button 'Save'
#     end
# 
#     expect(page).to have_text 'Mercer'
#   end
# 
# end
# describe 'Trainees' do
#   before :each do
#     signin_director
#     allow_any_instance_of(TraineePolicy).to receive('destroy?')
#       .and_return(true)
#   end
# 
#   it 'delete', js: true do
#     create_trainees(2, nil, 3000)
#     visit '/trainees'
#     fill_in 'filters_name', with: 'last'
#     click_button 'Find'
#     (1..2).each { |n| expect(page).to have_text "First#{3000 + n} Last#{3000 + n}" }
#     get_trainees.each do |trainee|
#       AlertConfirmer.accept_confirm_from do
#         click_on "destroy_trainee_#{trainee.id}_link"
# 
#       end
#       wait_for_ajax
#     end
#     (1..2).each { |n| expect(page).to_not have_text "First#{3000 + n} Last#{3000 + n}" }
#   end
# end
