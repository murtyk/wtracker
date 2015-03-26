require 'rails_helper'

describe "Trainee Interaction" do
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

      click_link 'new_trainee_interaction_link'
      wait_for_ajax

      fill_in 'trainee_interaction_employer_name', with: 't'
      click_on 'Find'
      wait_for_ajax
      fill_in 'trainee_interaction_comment', with: 'This employer is interested'
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'This employer is interested'

      Account.current_id = 1
      ti = TraineeInteraction.where(trainee_id: get_trainee_ids[0]).first
      find("#destroy_trainee_interaction_#{ti.id}_link").click
      # clink_link "destroy_trainee_interaction_link#{ti.id}"
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax

    end

    it 'new employer', js: true do

      page.driver.browser.manage().window().maximize()


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