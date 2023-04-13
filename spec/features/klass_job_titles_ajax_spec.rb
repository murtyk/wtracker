# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Klasses' do
#   before :each do
#     signin_admin
#     create_klasses(1)
#   end
#   after :each do
#     destroy_klasses
#     signout
#   end
#
#   describe 'ajax in show' do
#     it 'can add and remove job titles', js: true do
#       click_link 'new_klass_title_link'
#       # wait_for_ajax
#       fill_in 'klass_title_title', with: 'Title 1'
#       click_on 'Add'
#       # wait_for_ajax
#
#       expect(page).to have_text 'Title 1'
#
#       visit current_path # reloading page to cover some code in model
#       # get the title id to determine the click_link
#       Account.current_id = 1
#       Grant.current_id = 1
#       title = KlassTitle.where(title: 'Title 1').first
#       id = "destroy_klass_title_#{title.id}_link"
#       AlertConfirmer.accept_confirm_from do
#         click_link id
#       end
#
#       wait_for_ajax
#       expect(page).to_not have_text 'Title 1'
#     end
#
#     it 'removes new job title form on cancel', js: true do
#       click_link 'new_klass_title_link'
#       # wait_for_ajax
#       assert has_field?('klass_title_title')
#       click_on 'Cancel'
#       # wait_for_ajax
#       assert has_no_field?('klass_title_title')
#     end
#   end
# end
