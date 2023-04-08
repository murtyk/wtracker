# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Trainees' do
#   describe 'search by skills' do
#     before(:each) do
#       signin_autolead_director
#     end
#     after :each do
#       signout
#     end
#     it 'lets you find trainees with matching skills' do
#       account = Account.where(subdomain: 'njit').first
#       Account.current_id = account.id
#       Grant.current_id   = account.grants.first.id
#       klass = Klass.first
#
#       trainee1 = Trainee.create(first: 'first1', last: 'last1', email: 'first1@mail.com')
#       klass.trainees << trainee1
#       trainee2 = Trainee.create(first: 'first2', last: 'last2', email: 'first2@mail.com')
#       klass.trainees << trainee2
#       trainee1.create_job_search_profile(skills: 'java sdlc ajax',
#                                          location: 'Edison,NJ',
#                                          distance: 5,
#                                          key: 'key1')
#
#       trainee2.create_job_search_profile(skills: 'ruby jquery sdlc',
#                                          location: 'Edison,NJ',
#                                          distance: 5,
#                                          key: 'key2')
#       visit '/trainees/search_by_skills'
#
#       fill_in 'filters_skills', with: 'sdlc'
#       click_on 'Find'
#       expect(page).to have_text('first1 last1')
#       expect(page).to have_text('first2 last2')
#
#       fill_in 'filters_skills', with: 'java pmp'
#       click_on 'Find'
#       expect(page).to have_text('first1 last1')
#       expect(page).to_not have_text('first2 last2')
#     end
#   end
#   describe 'Trainees Index Page' do
#     before :each do
#       signin_admin
#       Account.current_id = 1
#       Grant.current_id = 1
#       klass = Klass.first
#       @klass_label = klass.to_label
#     end
#
#     it 'searches' do
#       Account.current_id = 1
#       Grant.current_id = 1
#
#       t1 = Trainee.create(first: 'First51', last: 'Last51', email: 'one@nomail.com')
#       t2 = Trainee.create(first: 'First52', last: 'Last52', email: 'two@nomail.com')
#
#       program = Program.first
#       college = College.first
#       k1 = program.klasses.create(name: 'TestClass1', college_id: college.id)
#       k2 = program.klasses.create(name: 'TestClass2', college_id: college.id)
#
#       k1.trainees << t1
#       k1.trainees << t2
#       k2.trainees << t1
#       k2.trainees << t2
#
#       href_link('trainees').click
#
#       klass = k1
#       select(klass.name, from: 'filters_klass_id')
#       click_button 'Find'
#
#       klass.trainees.each do |trainee|
#         expect(page).to have_text trainee.name
#       end
#
#       fill_in 'filters_name', with: 'last'
#       click_button 'Find'
#       (1..2).each { |n| expect(page).to have_text "First#{50 + n} Last#{50 + n}" }
#
#       fill_in 'filters_name', with: 'first'
#       click_button 'Find'
#       (1..2).each { |n| expect(page).to have_text "First#{50 + n} Last#{50 + n}" }
#     end
#   end
# end
