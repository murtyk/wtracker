require 'rails_helper'

describe 'Programs' do
  describe 'all rest actions except destroy' do
    before(:each) do
      signin_director
    end
    it 'lists' do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      href_link('programs').click
      account = Account.first
      Account.current_id = account.id
      programs = Program.all
      programs.each do |program|
        expect(page).to have_text(program.name)
        expect(page).to have_text(program.klasses.count)
      end
    end
    it 'shows' do
      href_link('programs').click
      account = Account.first
      Account.current_id = account.id
      Grant.current_id = account.grants.first.id
      program = Program.first
      click_link program.name
      expect(page).to have_text(program.name)
      program.klasses.each do |klass|
        expect(page).to have_text(klass.name)
        expect(page).to have_text(klass.trainees.count)
      end
    end
    it 'can create and update' do
      href_link('programs').click
      href_link('programs/new').click
      fill_in 'Name', with: 'Test Program'
      fill_in 'Hours', with: '300'
      select('health', from: 'Sector')

      click_button 'Add'
      expect(page).to have_text 'Test Program'

      href_link('programs').click
      account = Account.first
      Account.current_id = account.id
      Grant.current_id = account.grants.first.id
      program = Program.where(name: 'Test Program').first
      href_link("programs/#{program.id}/edit").click
      fill_in 'Name', with: 'changed name'
      click_button 'Update'
      href_link('programs').click
      expect(page).to have_text 'changed name'
    end
  end
end
