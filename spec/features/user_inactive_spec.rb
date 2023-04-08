# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'User De-activate' do
#   it 'de-activate an user' do
#     signin_director
#
#     href_link('users').click
#     href_link('users/2/edit').click
#     select('Not Active', from: 'Status')
#     click_button 'Update User'
#
#     Account.current_id = 1
#     user = User.find(2)
#     user_email = user.email
#
#     signout
#
#     fill_in 'email', with: user_email
#     fill_in 'password', with: 'password'
#     click_button 'Sign in'
#
#     expect(page).to have_text 'Your account was not activated yet.'
#
#     signin_director
#
#     href_link('users').click
#     href_link('users/2/edit').click
#     select('Active', from: 'Status')
#     click_button 'Update User'
#   end
# end
