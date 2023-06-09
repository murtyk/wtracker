# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Trainee' do
#   describe 'ajax in show' do
#     before :each do
#       signin_admin
#       visit('/trainees/1')
#     end
#
#     after :each do |example|
#       if example.exception
#         save_screenshot
#       end
#       # signout
#     end
#
#     it 'can add and delete assessments', js: true do
#       click_link 'new_trainee_assessment_link'
#       wait_for_ajax
#       select('Bennett Mechanical Comprehension', from: 'trainee_assessment_assessment_id')
#       fill_in 'Score', with: '2.2'
#       click_on 'Add'
#       wait_for_ajax
#       expect(page).to have_text 'Bennett Mechanical Comprehension'
#       expect(page).to have_text '2.2'
#       expect(page).to have_text 'Failed'
#
#       click_link 'new_trainee_assessment_link'
#       wait_for_ajax
#       select('KeyTrain', from: 'trainee_assessment_assessment_id')
#       fill_in 'Score', with: '4.2'
#       check 'Passed'
#       click_on 'Add'
#       wait_for_ajax
#       expect(page).to have_text 'KeyTrain'
#       expect(page).to have_text '4.2'
#       expect(page).to have_text 'Passed'
#
#       visit current_path # reloading page to cover some code in model
#       expect(page).to have_text 'Bennett Mechanical Comprehension'
#       expect(page).to have_text 'KeyTrain'
#
#       Account.current_id = 1
#       Grant.current_id = 1
#       trainee = Trainee.find 1
#       ta1 = trainee.trainee_assessments.first
#       ta2 = trainee.trainee_assessments.last
#       id1 = "destroy_trainee_assessment_#{ta1.id}_link"
#       id2 = "destroy_trainee_assessment_#{ta2.id}_link"
#
#       AlertConfirmer.accept_confirm_from do
#         click_link id1
#       end
#
#       wait_for_ajax
#       expect(page).to_not have_text 'Bennett Mechanical Comprehension'
#       expect(page).to have_text 'KeyTrain'
#
#       AlertConfirmer.accept_confirm_from do
#         click_link id2
#       end
#
#       wait_for_ajax
#       expect(page).to_not have_text 'KeyTrain'
#     end
#
#     it 'can apply to jobs', js: true do
#       Account.current_id = 1
#       Grant.current_id = 1
#       employer = Employer.find(1)
#       employer_name = employer.name
#
#       click_link 'new_trainee_submit_link'
#       wait_for_ajax
#       select employer_name, from: 'trainee_submit_employer_id'
#       fill_in 'Title', with: 'CNC Operator'
#       fill_in 'Applied on', with: '06/17/2013'
#
#       find_button('Add').trigger("click")
#       wait_for_ajax
#       10.times do
#         break if page.html.index(employer_name)
#         sleep 0.2
#       end
#
#       expect(page).to have_text employer_name
#       expect(page).to have_text 'CNC Operator'
#     end
#   end
# end
