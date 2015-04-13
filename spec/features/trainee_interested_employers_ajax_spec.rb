require 'rails_helper'

describe 'Trainee Interaction' do
  describe 'new' do
    before :each do
      signin_admin
      create_trainees(1)
    end
    after :each do
      destroy_trainees
      destroy_employers
    end

    it 'existing employer', js: true do
      expect(page).to have_text 'Enrolled' # klass status

      click_link 'new_trainee_interaction_link'
      wait_for_ajax

      fill_in 'trainee_interaction_employer_name', with: 't'
      click_on 'Find'
      wait_for_ajax

      comment = 'This employer hired.'
      fill_in 'trainee_interaction_comment', with: comment
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'No OJT'
      expect(page).to have_text comment

      # klass status
      expect(page).to_not have_text 'Enrolled'
      expect(page).to have_text 'Placed'

      Account.current_id = 1
      ti = TraineeInteraction.where(trainee_id: get_trainee_ids[0]).first
      find("#destroy_trainee_interaction_#{ti.id}_link").click
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax

      expect(page).to_not have_text 'No OJT'

      # klass status reverts to completed
      expect(page).to have_text 'Completed'

      # with OJT Enrolled
      click_link 'new_trainee_interaction_link'
      wait_for_ajax

      fill_in 'trainee_interaction_employer_name', with: 't'
      click_on 'Find'
      wait_for_ajax

      comment = 'This employer hired.'
      fill_in 'trainee_interaction_comment', with: comment
      select 'OJT Enrolled', from: 'trainee_interaction_status'
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'OJT Enrolled'
      expect(page).to have_text comment

      # klass status should not change
      expect(page).to have_text 'Completed'

      Account.current_id = 1
      ti = TraineeInteraction.where(trainee_id: get_trainee_ids[0]).first
      ti_id = ti.id
      find("#edit_trainee_interaction_#{ti_id}_link").click

      select 'OJT Completed', from: 'trainee_interaction_status'
      click_on 'Update'
      wait_for_ajax

      expect(page).to have_text 'OJT Completed'
      # klass status should change to placed
      expect(page).to have_text 'Placed'

      find("#edit_trainee_interaction_#{ti_id}_link").click
      fill_in 'trainee_interaction_termination_date', with: Date.tomorrow.to_s

      click_on 'Update'
      wait_for_ajax

      # klass status should change
      expect(page).to have_text 'Completed'
    end

    it 'new employer', js: true do
      page.driver.browser.manage.window.maximize

      click_link 'new_trainee_interaction_link'
      wait_for_ajax

      employer_name = 'Company101'
      click_on 'New'
      fill_in 'Name', with: employer_name
      select 'banking', from: 'Sectors'
      click_on 'Save'
      sleep 0.2
      wait_for_ajax
      sleep 1
      fill_in 'trainee_interaction_comment', with: "#{employer_name} is interested"
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text "#{employer_name} is interested"
    end
  end
end
