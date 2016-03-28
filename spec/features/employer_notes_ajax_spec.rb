require 'rails_helper'

describe 'EmployerNote', js: true do
  before :each do
    signin_admin
    destroy_employers
    create_employers(1)
  end
  after :each do
    destroy_employers
    signout
  end

  it 'user adds, updates, deletes a note, and can see short or long notes' do
    click_link 'new_employer_note_link'
    wait_for_ajax
    note = 'This is a' + ' note' * 30 + '. It should be long and display create date'
    fill_in 'employer_note_note', with: note
    click_on 'Add'

    expect(page).to have_text note.truncate(40)

    click_link "edit_employer_note_#{get_employer_notes_ids[0]}_link"
    wait_for_ajax
    fill_in 'employer_note_note', with: 'This is an updated note.'
    click_on 'Update'

    expect(page).to have_text 'This is an updated note'

    click_link 'new_employer_note_link'
    wait_for_ajax
    note = 'Another' + ' note' * 30 + ' . It should be long and display create date'
    fill_in 'employer_note_note', with: note
    click_on 'Add'
    wait_for_ajax
    expect(page).to have_text note.truncate(40)
    employer_note = get_employer_notes.first
    employer_note_id = employer_note.id
    click_button "employer_note_show_more_#{employer_note_id}"

    sleep 0.1
    wait_for_ajax
    expect(page).to have_text note

    click_button "employer_note_show_more_#{employer_note_id}"
    sleep 0.1
    wait_for_ajax
    expect(page).to have_text note.truncate(40)

    click_button 'employers_more_info_show'
    sleep 0.1
    wait_for_ajax
    expect(page).to have_text note

    click_button 'employers_more_info_show'
    wait_for_ajax
    sleep 0.1
    expect(page).to have_text note.truncate(40)

    AlertConfirmer.accept_confirm_from do
      click_link "destroy_employer_note_#{get_employer_notes_ids[0]}_link"
    end

    wait_for_ajax
    expect(page).to_not have_text 'This is an updated note'
  end
end
