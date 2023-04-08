# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Employers' do
#   describe 'existimg employers' do
#     before :each do
#       signin_director
#     end
#     after :each do
#       signout
#     end
#     it 'lists' do
#       href_link('employers').click
#       select('manufacturing', from: 'filters_sector_id')
#       click_button 'Find'
#       expect(page).to have_text('Wawa')
#       fill_in 'filters_name', with: 'tri'
#       click_button 'Find'
#       expect(page).to have_text('Trigyn')
#     end
#     it 'analyzes' do
#       href_link('employers/analysis').click
#       expect(page).to have_text('manufacturing')
#       click_link 'manufacturing'
#       expect(page).to have_text('Wawa')
#     end
#     it 'shows' do
#       href_link('employers').click
#       select('manufacturing', from: 'filters_sector_id')
#       click_button 'Find'
#       href_link('employers/1').click
#       expect(page).to have_text('Wawa')
#
#       expect(page).to have_text('Address:')
#       expect(page).to have_text('100 South Main Street')
#
#       expect(page).to have_text('Contacts')
#
#       expect(page).to have_text('Sectors')
#       expect(page).to have_text('manufacturing')
#
#       expect(page).to have_text('Trainees Hired')
#       expect(page).to have_text('Trainees Applied For Jobs')
#       expect(page).to have_text('Job Openings')
#
#       expect(page).to have_text('Notes')
#       expect(page).to have_text('Class Interactions')
#     end
#   end
#
#   describe 'in show' do
#     before :each do
#       signin_admin
#       visit('/employers/1')
#     end
#     after :each do
#       signout
#     end
#
#     it 'can edit' do
#       Account.current_id = 1
#       user_name = User.last.name
#       click_on 'edit_employer_1'
#       select user_name, from: 'Source'
#       click_on 'Save'
#       expect(page).to have_text 'Employer Information'
#       expect(page).to have_text user_name
#     end
#   end
#
#   describe 'new employer' do
#     before :each do
#       signin_admin
#     end
#     it 'can create' do
#       VCR.use_cassette('employer_create') do
#         href_link('employers/new').click
#         fill_in 'Name', with: 'Abc Inc.'
#         fill_in 'Street', with: '25 Rembrandt'
#         fill_in 'City', with: 'East Windsor'
#         select('NJ', from: 'employer_address_attributes_state')
#         fill_in 'Zip', with: '08520'
#
#         select('banking', from: 'Sectors')
#
#         click_button 'Save'
#         expect(page).to have_text 'Employer was successfully created.'
#       end
#     end
#   end
# end
