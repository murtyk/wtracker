# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'Dashboard' do
#   describe 'instructor should not have dashboard' do
#     it 'does not have dashboard menu' do
#       Account.current_id = 1
#       Grant.current_id = 1
#       klass = Klass.first
#       klass.klass_instructors.create(user_id: User.find_by(first: 'Eric').id)
#       signin_instructor
#       expect(page).to_not have_text 'Dashboard'
#     end
#   end
# end
