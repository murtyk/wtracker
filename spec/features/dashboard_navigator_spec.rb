# require 'rails_helper'
# 
# describe 'Dashboard' do
#   describe 'navigator' do
#     it 'visit events' do
#       Account.current_id = 1
#       melinda = User.where(email: 'melinda@mail.com').first
#       grant = Grant.first
#       Grant.current_id = grant.id
#       klass = Klass.first
#       klass.klass_navigators.create(user_id: melinda.id)
# 
#       signin_navigator
# 
#       expect(page).to have_selector('h1', text: 'Classes')
# 
#       signout
#     end
#   end
# end
