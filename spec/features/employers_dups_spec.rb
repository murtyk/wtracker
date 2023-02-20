# require 'rails_helper'
# 
# describe 'Employers' do
#   describe 'rejects duplicates' do
#     before :each do
#       signin_admin
#     end
#     it 'does not create no address duplicate' do
#       href_link('employers/new').click
#       fill_in 'Name', with: 'Name 1'
#       select('banking', from: 'Sectors')
# 
#       click_button 'Save'
#       expect(page).to have_text 'Employer was successfully created.'
# 
#       href_link('employers/new').click
#       fill_in 'Name', with: 'Name 1'
#       select('manufacturing', from: 'Sectors')
#       click_button 'Save'
# 
#       expect(page).to have_text 'duplicate employer Name 1'
#     end
#     it 'does not create with address duplicate' do
#       VCR.use_cassette('employer_create') do
#         href_link('employers/new').click
#         fill_in 'Name', with: 'Name 2'
#         select('banking', from: 'Sectors')
#         fill_in 'Street', with: '25 Rembrandt'
#         fill_in 'City', with: 'East Windsor'
#         select('NJ', from: 'employer_address_attributes_state')
#         fill_in 'Zip', with: '08520'
# 
#         click_button 'Save'
# 
#         expect(page).to have_text 'Employer was successfully created.'
# 
#         href_link('employers/new').click
#         fill_in 'Name', with: 'Name 2'
#         select('manufacturing', from: 'Sectors')
#         fill_in 'Street', with: '25 Rembrandt'
#         fill_in 'City', with: 'East Windsor'
#         select('NJ', from: 'employer_address_attributes_state')
#         fill_in 'Zip', with: '08520'
#         click_button 'Save'
# 
#         expect(page).to have_text 'duplicate employer Name 2'
#       end
#     end
# 
#     it 'prevents update with address duplicate' do
#       VCR.use_cassette('employer_create') do
#         href_link('employers/new').click
#         fill_in 'Name', with: 'Name 3'
#         select('banking', from: 'Sectors')
#         fill_in 'Street', with: '25 Rembrandt'
#         fill_in 'City', with: 'East Windsor'
#         select('NJ', from: 'employer_address_attributes_state')
#         fill_in 'Zip', with: '08520'
# 
#         click_button 'Save'
#         expect(page).to have_text 'Employer was successfully created.'
# 
#         href_link('employers/new').click
#         fill_in 'Name', with: 'Name 4'
#         select('banking', from: 'Sectors')
#         fill_in 'Street', with: '25 Rembrandt'
#         fill_in 'City', with: 'East Windsor'
#         select('NJ', from: 'employer_address_attributes_state')
#         fill_in 'Zip', with: '08520'
# 
#         click_button 'Save'
#         expect(page).to have_text 'Employer was successfully created.'
# 
#         Account.current_id = 1
#         employer = Employer.where(name: 'Name 4').first
# 
#         visit "/employers/#{employer.id}/edit"
#         fill_in 'Name', with: 'Name 3'
#         click_button 'Save'
# 
#         expect(page).to have_text 'duplicate employer Name 3'
#       end
#     end
# 
#     it 'prevents update without address duplicate' do
#       href_link('employers/new').click
#       fill_in 'Name', with: 'Name 5'
#       select('banking', from: 'Sectors')
# 
#       click_button 'Save'
#       expect(page).to have_text 'Employer was successfully created.'
# 
#       href_link('employers/new').click
#       fill_in 'Name', with: 'Name 6'
#       select('banking', from: 'Sectors')
# 
#       click_button 'Save'
#       expect(page).to have_text 'Employer was successfully created.'
# 
#       Account.current_id = 1
#       employer = Employer.where(name: 'Name 6').first
# 
#       visit "/employers/#{employer.id}/edit"
#       fill_in 'Name', with: 'Name 5'
#       click_button 'Save'
# 
#       expect(page).to have_text 'duplicate employer Name 5'
#     end
#   end
# end
