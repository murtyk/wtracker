require 'rails_helper'

describe 'Users' do
  describe 'all rest actions except destroy' do
    before(:each) do
      signin_director
    end
    it 'lists' do
      href_link('users').click
      users = User.all
      users.each do |user|
        expect(page).to have_text(user.name)
      end
    end
    it 'shows' do
      href_link('users').click
      href_link('users/1').click

      Account.current_id = 1
      user = User.find(1)
      expect(page).to have_text(user.first)
      expect(page).to have_text(user.last)
      expect(page).to have_text(user.email)
    end
    it 'create' do
      href_link('users').click
      href_link('users/new').click
      fill_in 'First', with: 'First1'
      fill_in 'Last', with: 'Last1'
      fill_in 'Location', with: 'Bergen'
      select('Navigator', from: 'user_role')
      fill_in 'Mobile Number', with: '9991112222'
      fill_in 'Email', with: 'first1@mail.com'
      fill_in 'Password', with: 'password'
      fill_in 'Comments', with: 'adding a navigator'

      click_button 'Create User'
      expect(page).to have_text 'First1 Last1'

      Account.current_id = 1
      user = User.where(first: 'First1').first
      href_link('users/' + user.id.to_s).click

      expect(page).to have_text user.email
      expect(page).to have_text '(999) 111-2222'
    end

    it 'update' do
      href_link('users').click
      href_link('users/2/edit').click
      fill_in 'Mobile Number', with: '9991113333'
      click_button 'Update User'
      expect(page).to have_text '(999) 111-3333'
    end
  end
end
