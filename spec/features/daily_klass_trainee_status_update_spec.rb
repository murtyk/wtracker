# require 'rails_helper'
# describe 'Daily Job to update Klass Trainee Status' do
#   before(:each) do
#     signin_admin
#     Account.current_id = 1
#     Grant.current_id = 1
#   end
# 
#   it 'daily job updates status' do
#     klass = FactoryGirl.create(:klass)
#     trainees = 3.times.map { FactoryGirl.create(:trainee) }
# 
#     klass.trainees << trainees
# 
#     klass.klass_trainees.update_all(status: 1)
#     klass.klass_trainees[2].update(status: 5)
# 
#     visit "/klasses/#{klass.id}"
#     expect(page).to have_text 'Enrolled - 2'
#     expect(page).to have_text 'Continuing Education - 1'
#     expect(page).to_not have_text 'Completed - 2'
# 
#     yd = Date.yesterday
#     yd -= 1.day if Date.today == Date.yesterday
# 
#     klass.update(end_date: yd)
#     DailyKlassTraineeStatus.perform
# 
#     visit "/klasses/#{klass.id}"
#     expect(page).to_not have_text 'Enrolled - 2'
#     expect(page).to have_text 'Continuing Education - 1'
#     expect(page).to have_text 'Completed - 2'
#   end
# end
