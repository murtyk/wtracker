# require 'rails_helper'
# 
# describe 'Reports' do
#   describe 'Trainees' do
#     before :each do
#       signin_admin
#     end
# 
#     it 'status report' do
#       Account.current_id = 1
#       Grant.current_id = Grant.first.id
#       college = College.first
#       klass = Program.first.klasses.create(name: 'A Class', college_id: college.id)
#       (1..3).each do |n|
#         attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com" }
#         t = Trainee.create(attr)
#         klass.klass_trainees.create(trainee_id: t.id, status: n)
#       end
# 
#       visit_report Report::TRAINEES_STATUS
#       select klass.name, from: 'Class'
#       click_on 'Find'
# 
#       sleep 1
# 
#       (1..3).each do |n|
#         expect(page).to have_text "First#{n} Last#{n}"
#       end
# 
#       expect(page).to have_text 'Enrolled'
#       expect(page).to have_text 'Completed'
#       expect(page).to have_text 'Dropped'
#       expect(page).to_not have_text 'Continuing Education'
#     end
#   end
# end
