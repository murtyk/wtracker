# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Grants' do
#   describe 'view and update grants' do
#     before(:each) do
#       signin_director
#     end
#     it 'lists' do
#       href_link('grants').click
#       account = Account.first
#       Account.current_id = account.id
#       grant = account.grants.first
#       expect(page).to have_text(grant.name)
#     end
#     it 'shows' do
#       account = Account.first
#       Account.current_id = account.id
#       grant = account.grants.first.decorate
#
#       href_link('grants').click
#       click_link grant.name
#
#       expect(page).to have_text(grant.name)
#       expect(page).to have_text(grant.spots)
#
#       grant.programs.each do |program|
#         expect(page).to have_text(program.name)
#       end
#     end
#
#     it 'can update' do
#       href_link('grants').click
#       account = Account.first
#       Account.current_id = account.id
#       grant = account.grants.first
#
#       # save_and_open_page
#
#       edit_link = find(:xpath, "//a[contains(@href,'/grants/#{grant.id}/edit')]")
#       # href_link("/grants/" + grant.id.to_s + "/edit").click
#       # puts edit_link
#
#       edit_link.click
#
#       fill_in 'Trainee Spots', with: '123'
#       click_button 'Update'
#       href_link('grants').click
#       expect(page).to have_text 'Spots: 123'
#     end
#   end
# end
