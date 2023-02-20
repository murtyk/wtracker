# require 'rails_helper'
# 
# describe 'side bars' do
#   before :each do
#     signin_director
#   end
# 
#   it 'configurable' do
#     Account.current_id = 1
#     Grant.current_id = 1
#     grant = Grant.find 1
# 
#     employer = Employer.first
# 
#     visit "/employers/#{employer.id}"
# 
#     expect(page).to have_text 'Trainees Hired'
#     expect(page).to have_text 'Trainees Applied For Jobs'
# 
#     grant.hide_a_side_bar(Sidebars::EMPLOYER_PAGE_TRAINEE_INFO)
# 
#     visit "/employers/#{employer.id}"
# 
#     expect(page).to_not have_text 'Trainees Hired'
#     expect(page).to_not have_text 'Trainees Applied For Jobs'
#   end
# end
