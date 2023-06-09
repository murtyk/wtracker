# frozen_string_literal: true
# require 'rails_helper'
#
# def create_klass_and_trainees
#   account = Account.find_by(subdomain: 'apple')
#   @account_id = account.id
#   Account.current_id = account.id
#   @grant_id = Grant.first.id
#   Grant.current_id = @grant_id
#   attrs = {first: 'John', last: 'Doe', email: 'johndoe@nomail.net'}
#   address_attrs = { line1: '765 Newman Springs Rd',
#                     city: 'Middletown',
#                     state: 'NJ',
#                     zip: '07738' }
#   attrs[:home_address_attributes] = address_attrs
#   t = Trainee.create(attrs)
#   @trainee_ids << t.id
#
#   attrs = {first: 'William', last: 'Smith', email: 'willsmith@nomail.net'}
#   address_attrs[:line1] = '761 Newman Springs Rd'
#   attrs[:home_address_attributes] = address_attrs
#   t = Trainee.create(attrs)
#   @trainee_ids << t.id
#
#   # create klass now
#   program = Program.first
#   program.klasses.create!(name: 'Some Class',
#                           description: 'Some Class',
#                           start_date: Date.tomorrow,
#                           end_date: Date.tomorrow + 1.year,
#                           credits: 5,
#                           training_hours: 100,
#                           college_id: College.first.id)
#
# end
#
# def all_trainees_near_by_colleges
#   visit '/trainees/near_by_colleges'
#   select 'All', from: 'filters_funding_source_id'
#   click_on 'Find'
# end
#
# describe 'near by colleges' do
#   before :each do
#     signin_applicants_admin
#   end
#   after :each do
#     # signout
#   end
#   it 'shows trainees near colleges' do
#     VCR.use_cassette('trainees_near_by_colleges') do
#       @trainee_ids = []
#       create_klass_and_trainees
#
#       all_trainees_near_by_colleges
#
#       expect(page).to have_text('John Doe')
#
#       visit '/klass_trainees/new?trainee_ids=' + @trainee_ids.join(',')
#       click_button 'Add'
#       expect(page).to have_text('Enrolled - 2')
#
#       all_trainees_near_by_colleges
#       expect(page).to_not have_text('John Doe')
#
#       Account.current_id = @account_id
#       Grant.current_id = @grant_id
#       KlassTrainee.last.delete
#       KlassTrainee.last.delete
#
#       all_trainees_near_by_colleges
#       expect(page).to have_text('John Doe')
#
#       Account.current_id = @account_id
#       Grant.current_id = @grant_id
#       trainee = Trainee.find @trainee_ids.first
#       trainee.update(status: 5)
#
#       all_trainees_near_by_colleges
#       expect(page).to_not have_text('John Doe')
#     end
#   end
# end
