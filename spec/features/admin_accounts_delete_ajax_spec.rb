# require 'rails_helper'
# 
# describe 'Administration' do
#   describe 'manage accounts' do
#     before(:each) do
#       signin_opero_admin
#     end
#     it 'can delete an account', js: true do
#       click_on 'New Account'
# 
#       fill_in 'Name', with: 'Test Client', match: :prefer_exact
#       fill_in 'Description', with: 'Test Client for testing'
#       fill_in 'Subdomain', with: 'test'
#       select('Grant Recipient', from: 'Client Type')
#       select('Active', from: 'Status')
# 
#       fill_in 'First Name', with: 'Robin'
#       fill_in 'Last Name', with: 'Hood'
#       fill_in 'Email', with: 'robinhood@mail.com'
#       fill_in 'Password', with: 'password'
#       fill_in 'Location', with: 'Edison, NJ'
# 
#       click_on 'Save'
# 
#       expect(page).to have_text 'Account was successfully created.'
#       visit '/admin/accounts'
#       expect(page).to have_text 'Test Client'
# 
#       account_id = Account.last.id
#       destroy_link_id = "destroy_account_#{account_id}_link"
# 
#       AlertConfirmer.accept_confirm_from do
#         click_link destroy_link_id
#       end
# 
#       5.times do
#         break unless page.html.index("Test Client")
#         sleep 0.5
#       end
#       expect(page).to_not have_text 'Test Client'
#     end
#   end
# end
