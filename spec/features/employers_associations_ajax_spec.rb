require 'rails_helper'

describe 'Employers' do
  include AjaxHelper

  before :each do
    signin_admin
    create_employers(1)
  end
  after :each do
    destroy_employers
  end

  describe 'contacts' do
    it 'adds, updates and deletes', js: true do
      click_link new_link_id('contact')
      wait_for_ajax
      fill_in 'contact_first', with: 'Luciano'
      fill_in 'contact_last', with: 'Pavarotti'
      fill_in 'contact_title', with: 'Tenor'
      fill_in 'contact_email', with: 'luciano@mail.com'
      fill_in 'contact_land_no', with: '888-999-2222'
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'Luciano Pavarotti'
      expect(page).to have_text 'luciano@mail.com'
      expect(page).to_not have_text '(m)'

      employer = get_employers.first
      contact = employer.contacts.first

      click_link edit_link_id(contact)
      fill_in 'contact_mobile_no', with: '999-888-7777'
      click_on 'Update'

      expect(page).to have_text '(m)'

      employer = get_employers.first
      contact = employer.contacts.first
      contact_name = contact.name

      AlertConfirmer.accept_confirm_from do
        click_link destroy_link_id(contact)
      end

      sleep 1
      expect(page).to_not have_text contact_name
    end
  end

  describe 'manage sectors- ajax' do
    it 'can add and remove sectors', js: true do
      click_link new_link_id('employer_sector')
      wait_for_ajax
      select('banking', from: 'employer_sector_sector_id')
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'banking'
      es = get_employers.first.employer_sectors.first
      sector_name = es.sector_name
      expect(page).to have_text sector_name

      AlertConfirmer.accept_confirm_from do
        page.find_by_id(destroy_link_id(es)).click
      end

      sleep 1
      expect(page).to_not have_text sector_name
    end
  end

  describe 'can add job openings - ajax' do
    it 'can add job openings', js: true do
      click_link new_link_id('job_opening')
      wait_for_ajax
      fill_in 'job_opening_jobs_no', with: '3'
      fill_in 'job_opening_skills', with: 'CNC set up'
      click_on 'Add'

      expect(page).to have_text 'CNC set up'
    end
  end

  describe 'notes - ajax' do
    it 'adds and deletes', js: true do
      click_link new_link_id('employer_note')
      wait_for_ajax
      fill_in 'employer_note_note', with: 'test note'
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'test note'

      note = get_employers.first.employer_notes.first

      AlertConfirmer.accept_confirm_from do
        page.find_by_id(destroy_link_id(note)).click
      end

      sleep 1
      expect(page).to_not have_text 'test note'
    end
  end
end
