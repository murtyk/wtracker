# require 'rails_helper'
# 
# describe 'Klass trainee' do
#   describe 'status' do
#     before :each do
#       signin_admin
#       create_employers(1)
#       create_klasses(1, 1)
#     end
# 
#     after :each do
#       destroy_all_created
#       signout
#     end
# 
#     it 'change to placed', js: true do
#       visit "/klasses/#{get_klasses_ids[0]}"
# 
#       kt_ids = get_klass_trainee_ids
#       kt_id = kt_ids[0]
#       edit_link_id = "edit_klass_trainee_#{kt_id}_link"
#       click_link edit_link_id
# 
#       wait_for_ajax
#       select 'Placed', from: 'klass_trainee_status'
#       wait_for_ajax
# 
#       fill_in 'klass_trainee_employer_name', with: 'Company'
#       click_on 'Find'
#       wait_for_ajax
# 
#       fill_in 'Start date', with: '05/12/2014'
#       fill_in 'Hire title', with: 'Mechanic'
#       fill_in 'Hire salary', with: '12'
# 
#       click_on 'Update'
#       wait_for_ajax
#       expect(page).to have_text 'Placed - 1'
# 
#       message = page.accept_alert do
#         click_link edit_link_id
#       end
#       expect(message).to include('Can not change status of a placed trainee.')
#     end
#   end
# end
