# require 'rails_helper'
# 
# describe 'Employer' do
#   describe 'Email to Near By Trainees' do
#     before :each do
#       signin_admin
#     end
#     after :each do
#       signout
#     end
# 
#     it 'shows near by trainees and sends them an email' do
#       Account.current_id = 1
#       Grant.current_id = 1
# 
#       address_attrs = { line1: '50 Millstone Road',
#                         city: 'East Windsor',
#                         state: 'NJ',
#                         zip: '08520',
#                         longitude: -74.56,
#                         latitude: 40.29 }
#       source_id = EmployerSource.first.id
#       name = 'Perceptive Informatics Inc'
# 
#       employer = Employer.create(name: name,
#                                  employer_source_id: source_id,
#                                  address_attributes: address_attrs)
# 
#       visit "/employers/#{employer.id}"
# 
#       click_on 'Near By Trainees'
#       expect(page).to have_text 'Paul Harris'
# 
#       fill_in 'Subject', with: 'this is subject'
#       fill_in 'Content', with: 'this is content'
# 
#       click_on 'Send'
#       expect(page).to have_text 'email was successfully scheduled for delivery.'
#     end
#   end
# end
