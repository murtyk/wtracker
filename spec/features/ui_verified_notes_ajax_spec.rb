# require 'rails_helper'
# 
# describe 'UiVerifiedNote', js: true do
#   describe 'Trainee Page' do
#     before :each do
#       signin_admin
#       destroy_trainees
#       create_trainees(1)
#     end
#     after :each do
#       destroy_trainees
#     end
#     it 'user adds and deleted an ui verified note' do
#       click_link "trainee_#{get_trainee_ids[0]}_new_ui_verified_note_link"
#       wait_for_ajax
#       fill_in 'ui_verified_note_notes', with: 'This is a note.' \
#                                           ' It should be long and display create date'
#       click_on 'Add'
#       wait_for_ajax
#       expect(page).to have_text 'This is a note'
# 
#       AlertConfirmer.accept_confirm_from do
#         click_link "destroy_ui_verified_note_#{get_ui_verified_notes_ids[0]}_link"
#       end
# 
#       wait_for_ajax
#       expect(page).to_not have_text 'This is a note'
#     end
#   end
# end
