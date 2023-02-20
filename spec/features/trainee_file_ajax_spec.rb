# require 'rails_helper'
# 
# def resume
#   "#{Rails.root}/spec/fixtures/RESUME.docx"
# end
# 
# def cover_letter
#   "#{Rails.root}/spec/fixtures/COVER LETTER.pdf"
# end
# describe 'TraineeFile', js: true do
#   describe 'can attach multiple files' do
#     before :each do
#       signin_admin
#       create_trainees(1)
# 
#       @filepath = resume
#       allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
#       allow(Amazon).to receive(:file_url).and_return(@filepath)
#       allow(Amazon).to receive(:original_file_name).and_return('RESUME.docx')
#       allow(Amazon).to receive(:delete_file).and_return(nil)
#     end
# 
#     after :each do
#       destroy_all_created
#     end
# 
#     it 'allows attachments' do
#       click_link 'new_trainee_file_link'
#       @filepath = cover_letter
# 
#       page.attach_file 'trainee_file_file', @filepath
#       wait_for_ajax
#       fill_in 'Notes', with: 'Cover Letter'
#       click_on 'Add File'
#       wait_for_ajax
# 
#       expect(page).to have_text 'Cover Letter'
# 
#       delete_btn_id = first(:xpath, "//*[contains(@id, 'destroy_trainee_file')]")[:id]
# 
#       AlertConfirmer.accept_confirm_from do
#         click_on delete_btn_id
#       end
# 
#       15.times do
#         break if page.html.index("Cover Letter").to_i == 0
#         sleep 1
#       end
# 
#       expect(page).to_not have_text 'Cover Letter'
#     end
#   end
# end
