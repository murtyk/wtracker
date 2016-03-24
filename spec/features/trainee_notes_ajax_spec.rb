require 'rails_helper'

describe 'TraineeNote', js: true do
  describe 'Trainee Page' do
    before :each do
      signin_admin
      destroy_trainees
      create_trainees(1)
    end
    after :each do
      destroy_trainees
    end
    it 'user adds, updates and deleted a note' do
      click_link "trainee_#{get_trainee_ids[0]}_new_trainee_note_link"
      wait_for_ajax
      fill_in 'trainee_note_notes', with: 'This is a note.' \
                                          ' It should be long and display create date'
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'This is a note'

      click_link "edit_trainee_note_#{get_trainee_notes_ids[0]}_link"
      wait_for_ajax
      fill_in 'trainee_note_notes', with: 'This is an updated note. ' \
                                          'It should be long and display create date'
      click_on 'Update'
      wait_for_ajax
      expect(page).to have_text 'This is an updated note'

      AlertConfirmer.accept_confirm_from do
        click_link "destroy_trainee_note_#{get_trainee_notes_ids[0]}_link"

      end
      wait_for_ajax
      expect(page).to_not have_text 'This is an updated note'
    end
  end

  describe 'Class Page' do
    before :each do
      signin_admin
      destroy_trainees
      destroy_klasses
      create_klasses(2, 1)
    end
    after :each do
      destroy_trainees
      destroy_klasses
    end
    it 'create new notes for each trainee' do
      # we have 2 classes with one trainee in each
      # lets add the other trainee to each class

      get_klasses.each do |klass|
        visit "/klasses/#{klass.id}"
        click_link 'new_klass_trainee_link'
        wait_for_ajax
        select('First', from: 'klass_trainee_trainee_id')
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

      # notes should be visible on trainee page

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
    end
  end
end
