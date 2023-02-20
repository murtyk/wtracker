# require 'rails_helper'
# 
# describe 'Employer and Class Interaction' do
#   before :each do
#     signin_admin
#     destroy_employers
#     Account.current_id = 1
#     Grant.current_id = 1
#     @klass = Klass.first
#     @event = @klass.klass_events.find_by(name: "Information Session")
#     @event_label = @event.selection_name
#   end
#   after :each do
#     destroy_employers
#   end
#   it 'can create and update', js: true do
#     visit '/klass_interactions/new'
#     wait_for_ajax
#     fill_in 'Name', with: 'Company Abc Inc.'
# 
#     select('banking', from: 'Sectors')
#     select(@event_label, from: 'Event')
# 
#     click_on 'Save'
#     expect(page).to have_text 'Class Interaction successfully created.'
# 
#     click_on 'Expand'
#     expect(page).to have_text 'Interested'
# 
#     myid = page.find('#klass_interactions')
#            .first(:xpath, "//*[contains(@id, 'edit_klass_interaction')]")[:id]
#     click_link myid
# 
#     select 'Confirmed', from: 'Status'
#     click_on 'Update'
# 
#     wait_for_ajax
# 
#     expect(page).to have_text 'Confirmed'
# 
#     expect(page).to_not have_text 'Interested'
# 
#     klass_href = page.find('#klass_interactions')
#                  .first('a', "//*[contains(@href='/klasses')]")[:href]
#     visit klass_href
#     click_on 'Expand All'
# 
#     sleep 0.2
#     events = page.find('#Information_Session_events')
# 
#     expect(events).to have_text 'Confirmed'
#     myid = events.first(:xpath, "//*[contains(@id, 'destroy_klass_interaction')]")[:id]
# 
#     AlertConfirmer.accept_confirm_from do
#       click_link myid
#     end
# 
#     10.times do
#       break if page.html.index("Confirmed").to_i == 0
#       sleep 1
#     end
#     expect(page).to_not have_text 'Confirmed'
#   end
# end
