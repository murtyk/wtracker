require 'rails_helper'
describe 'klasses' do
  describe 'existing klasses' do
    before(:each) do
      signin_admin
      Account.current_id = 1
      Grant.current_id = 1
      @k = Klass.find(1)
      @program = @k.program
    end

    it 'lists' do
      href_link('klasses').click
      expect(page).to have_text @k.name
    end

    it 'shows' do
      href_link('klasses').click
      expect(page).to have_text @k.name
      href_link("klasses/#{@k.id}").click
      expect(page).to have_text @k.name
      expect(page).to have_text @program.name

      expect(page).to have_text 'Certificates'
      expect(page).to have_text 'Relevant Job Titles'
      expect(page).to have_text 'Navigators'
      expect(page).to have_text 'Instructors'
      expect(page).to have_text 'Events'
      expect(page).to have_text 'Employer Interactions'
      expect(page).to have_text 'Trainees'
    end
  end

  describe 'create and update' do
    before :each do
      signin_admin
    end

    it 'can create' do
      visit '/klasses'

      page.first(:css, '#new_klass_link').click
      fill_in 'Name', with: 'Fab Metals'
      click_on 'Save'

      expect(page).to have_text 'Class Information'
      expect(page).to have_text 'Fab Metals'
    end

    it 'can update' do
      Account.current_id = 1
      Grant.current_id = 1
      k = Klass.find(1)
      visit("/klasses/#{k.id}")

      click_on "edit_klass_#{k.id}"
      fill_in 'Description', with: 'changed description'
      click_on 'Save'
      expect(page).to have_text 'Class Information'
      expect(page).to have_text 'changed description'
    end
  end
end
