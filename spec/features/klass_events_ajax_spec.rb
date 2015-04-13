require 'rails_helper'

describe 'Klass page' do
  describe 'can do events' do
    before :each do
      signin_admin
      create_klasses(1)
    end

    after :each do
      destroy_klasses
    end

    it 'can add event', js: true do
      # klass_ids = get_klasses_ids
      # Account.current_id = 1
      # Grant.current_id = 1
      # klass = Klass.find(klass_ids[0])
      # first_event = klass.klass_events.first

      click_link 'new_klass_event_link'
      wait_for_ajax
      page.first('.add-on').click
      wait_for_ajax
      click_on 'Prescreening'
      wait_for_ajax
      fill_in 'klass_event_event_date', with: '12/28/2013'
      fill_in 'klass_event_notes', with: 'notes from rspec'
      fill_in 'klass_event_start_time_hr', with: '9'
      fill_in 'klass_event_end_time_hr', with: '1'

      # now search for employer wawa
      fill_in 'name', with: 'w'
      click_on 'Find'
      wait_for_ajax
      expect(page).to have_text 'Wawa'
      select('Wawa', from: 'select_employers')
      click_button 'add-selected-employers'

      click_on 'Save'
      wait_for_ajax

      click_on 'Expand All'
      expect(page).to have_text 'Prescreening'
    end

    it 'can delete event', js: true do
      # test edit an existing event
      click_on 'Expand All'
      expect(page).to have_text 'Graduation'

      klass_ids = get_klasses_ids
      Account.current_id = 1
      Grant.current_id = 1
      klass = Klass.find(klass_ids[0])
      klass_event_name = 'Graduation'
      klass_event = klass.klass_events.where(name: klass_event_name).first
      # puts klass_event.inspect
      expect(page).to have_text klass_event_name

      # save_screenshot('c:/temp/klasseventdelete')
      click_link "destroy_klass_event_link#{klass_event.id}"
      sleep 0.1
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      visit("/klasses/#{klass_ids[0]}")
      click_on 'Expand All'
      expect(page).to_not have_text klass_event_name
    end

    it 'can change event', js: true do
      click_on 'Expand All'

      Account.current_id = 1
      Grant.current_id = 1
      klass_ids = get_klasses_ids
      klass = Klass.find(klass_ids[0])
      event_name = 'Prescreening'
      event = klass.klass_events.where(name: event_name).first

      click_link "edit_klass_event_link#{event.id}"
      wait_for_ajax

      page.first('.combobox-clear').click
      page.first('.add-on').click
      click_on 'Graduation'

      click_on 'Save'
      wait_for_ajax
      click_on 'Expand All'
      expect(page).to_not have_text event_name
    end
  end
end
