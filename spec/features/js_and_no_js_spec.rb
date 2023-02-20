# require 'rails_helper'
# describe 'signin page' do
#   it 'no js' do
#     visit '/login'
#     expect(page).to have_text 'Remember Me'
#   end
#   it 'with js', js: true do
#     puts Capybara.app_host
#     puts Capybara.server_port
#     visit '/login'
#     expect(page).to have_text 'Remember Me'
#   end
#   it 'with js', js: true do
#     visit new_user_session_path
#     expect(page).to have_text 'Remember Me'
#   end
#   it 'full url with js', js: true do
#     visit "#{Capybara.app_host}:#{Capybara.server_port}/login"
#     expect(page).to have_text 'Remember Me'
#   end
# end
