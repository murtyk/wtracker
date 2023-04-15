# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Klasses' do
#   describe 'instructors' do
#     before :each do
#       signin_admin
#       create_klasses(1)
#     end
#     after :each do
#       destroy_klasses
#       signout
#     end
#
#     it 'can add and remove instructors', js: true do
#       click_link 'new_klass_instructor_link'
#       # wait_for_ajax
#       name = 'Eric Clapton'
#       select(name, from: 'klass_instructor_user_id')
#       click_on 'Add'
#       # wait_for_ajax
#       expect(page).to have_text name
#       klass = get_klasses.first
#       klass_instructor = klass.klass_instructors.first
#       id = "destroy_klass_instructor_#{klass_instructor.id}_link"
#       AlertConfirmer.accept_confirm_from do
#         click_link id
#       end
#
#       wait_for_ajax
#       expect(page).to_not have_text name
#     end
#
#     it 'removes add instructor form on cancel', js: true do
#       click_link 'new_klass_instructor_link'
#       # wait_for_ajax
#       assert has_field?('klass_instructor_user_id')
#       click_on 'Cancel'
#       # wait_for_ajax
#       assert has_no_field?('klass_instructor_user_id')
#     end
#   end
# end
