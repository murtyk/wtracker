# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Klass Schedules' do
#   describe 'can do events' do
#     before :each do
#       signin_admin
#     end
#
#     after :each do
#       signout
#     end
#
#     it 'schedules when entered' do
#       visit '/klasses'
#       page.first(:css, '#new_klass_link').click
#       fill_in 'Name', with: 'Fab Metals 1'
#
#       check 'klass_klass_schedules_attributes_0_scheduled'
#       fill_in 'klass[klass_schedules_attributes][0][start_time_hr]', with: '9'
#       fill_in 'klass[klass_schedules_attributes][0][end_time_hr]', with: '2'
#
#       check 'klass_klass_schedules_attributes_4_scheduled'
#       fill_in 'klass[klass_schedules_attributes][4][start_time_hr]', with: '10'
#       fill_in 'klass[klass_schedules_attributes][4][end_time_hr]', with: '3'
#
#       click_on 'Save'
#
#       click_on 'Schedule'
#
#       expect(page).to have_selector('td', text: 'Monday')
#       expect(page).to have_selector('td', text: '9:00 am')
#       expect(page).to have_selector('td', text: '-- 2:00 pm')
#       expect(page).to have_selector('td', text: 'Friday')
#       expect(page).to have_selector('td', text: '10:00 am')
#       expect(page).to have_selector('td', text: '-- 3:00 pm')
#     end
#   end
# end
