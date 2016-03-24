require 'rails_helper'

describe 'Employers' do
  describe 'do class interactions -ajax', js: true do
    before :each do
      signin_admin
    end

    after :each do
      signout
    end

    it 'can add class interactions' do
      destroy_klasses
      destroy_employers
      create_klasses(1)
      create_employers(1)

      click_on 'new_klass_interaction_link'
      wait_for_ajax
      expect(page).to have_text 'New Class Interaction'
      klass = get_klasses.first
      klass_name = "#{klass.college.name} - #{klass.name}"

      select(klass_name, from: 'klass_interaction_klass_id')
      klass_event = klass.klass_events.find_by(name: "Information Session")

      # event_label = "#{klass_event.event_date} - #{klass_event.name}"
      select(klass_event.selection_name, from: 'klass_interaction_klass_event_id')
      select('Confirmed', from: 'klass_interaction_status')
      click_button 'Save'

      20.times do
        break if page.html.index(klass_name)
        sleep 0.5
      end

      expect(page).to have_text klass_name

      click_button 'Expand'
      sleep 0.2
      expect(page).to have_text 'Confirmed'

      # can update
      employer = get_employers.first
      visit "/employers/#{employer.id}"

      employer = get_employers.first
      klass_interaction = employer.klass_interactions.first

      find_button('Expand').click
      sleep 0.2
      click_link("edit_klass_interaction_#{klass_interaction.id}_link")

      wait_for_ajax

      select('Cancelled', from: 'klass_interaction_status')
      fill_in 'klass_interaction_klass_event_notes', with: 'KI Notes'
      click_button 'Update'
      wait_for_ajax
      expect(page).to have_text 'Cancelled'

      # delete
      klass = get_klasses.first
      klass_id = klass.id

      visit "/klasses/#{klass_id}"
      click_on 'Expand All'

      employer = get_employers.first
      klass_interaction = employer.klass_interactions.first
      employer_name = employer.name
      destroy_id = destroy_link_id(klass_interaction)

      expect(page).to have_text employer_name

      AlertConfirmer.accept_confirm_from do
        click_link destroy_id
      end

      wait_for_ajax

      10.times do
        break if page.html.index(employer_name).to_i == 0
        sleep 0.5
      end

      expect(page).to_not have_text employer_name

      destroy_klasses
      destroy_employers
    end
  end
end
