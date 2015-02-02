require 'rails_helper'
RSpec.configure do |config|
  config.order = "defined"
end

describe "Trainee" do
  describe 'notes' do

    before :each do
      signin_admin
    end
    it 'user creates a new note', js: true do
      destroy_trainees
      create_trainees(1)

      click_link "trainee_#{get_trainee_ids[0]}_new_trainee_note_link"
      wait_for_ajax
      fill_in 'trainee_note_notes', with: 'This is a note. It should be long and display create date'
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'This is a note'

    end

    it 'user updates a note', js: true do
      visit "/trainees/#{get_trainee_ids[0]}"
      click_link "edit_trainee_note_#{get_trainee_notes_ids[0]}_link"
      wait_for_ajax
      fill_in 'trainee_note_notes', with: 'This is an updated note. It should be long and display create date'
      click_on 'Update'
      wait_for_ajax
      expect(page).to have_text 'This is an updated note'
    end

    it 'user deletes a note', js: true do
      visit "/trainees/#{get_trainee_ids[0]}"
      click_link "destroy_trainee_note_#{get_trainee_notes_ids[0]}_link"
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'This is an updated note'
      destroy_trainees
    end

  end

end

describe "Class Page" do
  describe "trainees notes" do
    before :each do
      signin_admin
    end
    it 'create new notes for each trainee', js: true do
      destroy_trainees
      destroy_klasses
      create_klasses(2, 1)

      #we have 2 classes with one trainee in each
      #lets add the other trainee to each class

      get_klasses.each do |klass|
        visit "/klasses/#{klass.id}"
        click_link 'new_klass_trainee_link'
        wait_for_ajax
        select('First', :from => 'klass_trainee_trainee_id')
        click_on 'Add'
        wait_for_ajax
      end

      klass_names = []
      get_klasses.each do |klass|
        klass_names.push klass.name
        visit "/klasses/#{klass.id}"
        click_on 'Show More'
        Account.current_id = 1
        Grant.current_id = 1
        klass.trainees.each do |trainee|
          click_link "trainee_#{trainee.id}_new_trainee_note_link"
          wait_for_ajax
          fill_in 'trainee_note_notes', with: "This is a note from #{klass.name}"
          click_on 'Add'
          wait_for_ajax
        end
      end

      #notes should be visible on trainee page

      get_trainee_ids.each do |trainee_id|
        visit "/trainees/#{trainee_id}"
        klass_names.each do |klass_name|
          expect(page).to have_text "This is a note from #{klass_name}"
        end
      end

      get_klasses_ids.each do |klass_id|
        visit "/klasses/#{klass_id}"
        click_on 'Show More'
        klass_names.each do |klass_name|
          expect(page).to have_text "This is a note from #{klass_name}"
        end
      end
      destroy_trainees
      destroy_klasses

    end
  end
end