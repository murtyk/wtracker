# require 'rails_helper'
# 
# describe 'Klass Calendar' do
#   describe 'can do events' do
#     before :each do
#       signin_admin
#     end
#     describe "when start and end dates are missing" do
#       it 'will not have a calendar' do
#       visit '/klasses'
#       page.first(:css, '#new_klass_link').click
#       fill_in 'Name', with: 'Fab Metals 1'
#       click_on 'Save'
# 
#       expect(page).to have_text 'Please define start and end dates for the class'
#       end
#     end
# 
#     describe "when start and end dates are valid" do
#       before :each do
#         visit '/klasses'
#         page.first(:css, '#new_klass_link').click
#         fill_in 'Name', with: 'Fab Metals 2'
# 
#         start_date = Date.today.strftime("%m/%d/%Y")
#         end_date = (Date.today + 60.days).strftime("%m/%d/%Y")
# 
#         fill_in 'Start date', with: start_date
#         fill_in 'End date', with: end_date
#         click_on 'Save'
#       end
#       it 'will have a calendar when start and end dates are provided' do
#         expect(page).to_not have_text 'Please define start and end dates for the class'
# 
#         monday = (Date.today + 8.days).beginning_of_week
#         expect(page).to have_selector('th', text: monday.strftime('%d-%b'))
#         expect(page).to have_selector('td', text: 'Information Session')
#       end
# 
#       it 'will go to klass event page when clicked on event in calendar' do
#         # cell = find('td', text: "Information Session")
#         # cell.click
#         # sleep 0.5
#         # expect(page).to have_text 'Class Event'
#         # expect(page).to have_text 'Select Employers and Add them for interaction'
#       end
#     end
#   end
# end
