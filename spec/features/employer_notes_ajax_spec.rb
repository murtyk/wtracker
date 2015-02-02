require 'rails_helper'
RSpec.configure do |config|
  config.order = "defined"
end

describe "Employer" do
  describe 'notes' do

    before :each do
      signin_admin
    end

    it 'creates', js: true do
      destroy_employers
      create_employers(1)
      click_link "new_employer_note_link"
      wait_for_ajax
      note = 'This is a note note note note note note note note note note note note note note note note note note note note . It should be long and display create date'
      fill_in 'employer_note_note', with: note
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text note.truncate(40)

    end

    it 'updates', js: true do
      visit "/employers/#{get_employer_ids[0]}"
      click_link "edit_employer_note_#{get_employer_notes_ids[0]}_link"
      wait_for_ajax
      fill_in 'employer_note_note', with: 'This is an updated note.'
      click_on 'Update'
      wait_for_ajax
      sleep 0.5

      expect(page).to have_text 'This is an updated note'
    end


    it 'shows short or full note', js: true do
      visit "/employers/#{get_employer_ids[0]}"
      click_link "new_employer_note_link"
      wait_for_ajax
      note = 'Another note note note note note note note note note note note note note note note note note note note note . It should be long and display create date'
      fill_in 'employer_note_note', with: note
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text note.truncate(40)
      employer_note = get_employer_notes.first
      employer_note_id = employer_note.id
      click_button "employer_note_show_more_#{employer_note_id}"
      sleep 0.5
      expect(page).to have_text note

      click_button "employer_note_show_more_#{employer_note_id}"
      sleep 0.5
      expect(page).to have_text note.truncate(40)

      click_button "employers_more_info_show"
      sleep 0.5
      expect(page).to have_text note

      click_button "employers_more_info_show"
      sleep 0.5
      expect(page).to have_text note.truncate(40)

    end


    it 'deletes', js: true do
      employer_id = get_employer_ids[0].to_s
      employer_notes_id = get_employer_notes_ids[0].to_s

      visit "/employers/#{employer_id}"
      click_link "destroy_employer_note_#{employer_notes_id}_link"
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'This is an updated note'
      destroy_employers
    end

  end

end
