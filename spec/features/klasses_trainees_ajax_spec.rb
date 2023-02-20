# require 'rails_helper'
# 
# describe 'Klasses' do
#   describe 'klass trainees - ajax' do
#     before :each do
#       signin_admin
#       destroy_all_created
#       create_trainees(1)
#       create_klasses(1)
#     end
# 
#     after :each do
#       destroy_all_created
#     end
# 
#     it 'can add trainee, edit status and remove trainee', js: true do
#       name = 'First1 Last1'
#       expect(page).to_not have_text name
# 
#       click_link 'new_klass_trainee_link'
#       wait_for_ajax
#       select(name, from: 'klass_trainee_trainee_id')
#       click_on 'Add'
#       wait_for_ajax
#       expect(page).to have_text name
# 
#       expect(page).to_not have_text 'Completed - 1'
# 
#       klass = get_klasses.first
#       klass_trainee_id = klass.klass_trainees.first.id
# 
#       id = "edit_klass_trainee_#{klass_trainee_id}_link"
#       sleep 1
#       click_link id
#       wait_for_ajax
#       select 'Completed', from: 'klass_trainee_status'
#       click_on 'Update'
#       wait_for_ajax
#       expect(page).to have_text 'Completed - 1'
# 
#       expect(page).to have_text name
# 
#       id = "destroy_klass_trainee_#{klass_trainee_id}_link"
#       AlertConfirmer.accept_confirm_from do
#         click_link id
# 
#       end
#       wait_for_ajax
#       expect(page).to_not have_text name
#     end
#   end
# end
