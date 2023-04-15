# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Reports' do
#   describe 'Trainees' do
#     before :each do
#       signin_admin
#
#       Account.current_id = 1
#       Grant.current_id = 1
#       emp = Employer.first
#       tr  = KlassTrainee.first.trainee
#       tr.trainee_submits.create(employer_id: emp.id, title: 'Analyst',
#                                 applied_on: Date.current - 1.day)
#       @trainee_name = tr.name
#       @company_name = emp.name
#     end
#
#     after :each do
#       signout
#     end
#
#     it 'jobs applied' do
#       visit_report Report::JOBS_APPLIED
#       select 'All', from: 'Class'
#       click_on 'Find'
#       expect(page).to have_text @trainee_name
#       expect(page).to have_text 'Analyst'
#     end
#   end
# end
