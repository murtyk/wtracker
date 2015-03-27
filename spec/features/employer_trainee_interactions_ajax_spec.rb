require 'rails_helper'

describe "Employers" do

  describe 'trainee interactions' do

    before :each do
      signin_admin
      destroy_all_created
      create_klasses(1,3)
      create_employers(1)
    end

    after :each do
      destroy_all_created
    end

    it 'can add, change and delete', js: true do

      click_link 'new_trainee_interaction_link'
      wait_for_ajax
      klass = get_klasses.first
      klass_label = "#{klass.college.name} - #{klass.name}"
      select klass_label, from: 'trainee_interaction_klass_id'
      wait_for_ajax

      get_trainees.each do |t|
        select t.name, from: 'trainee_interaction_trainee_ids'
      end

      fill_in 'trainee_interaction_comment', with: 'test test test'
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'Interested'

      get_trainees.each do |t|
        expect(page).to have_text t.name
      end

      expect(page).to_not have_text 'Interview'

      # move one to interview status
      myid = page.find("#trainees_Interested").first(:xpath, "//*[contains(@id, 'edit_trainee_interaction_')]")[:id]
      click_link myid
      wait_for_ajax

      fill_in 'trainee_interaction_interview_date', with: '08/09/2013'
      fill_in 'trainee_interaction_interviewer', with: 'Clinton'
      click_on 'Update'
      wait_for_ajax
      expect(page).to have_text 'Interview'

      # move the other to offer status
      myid = page.find("#trainee_interactions").first(:xpath, "//*[contains(@id, 'edit_trainee_interaction_')]")[:id]

      click_link myid
      wait_for_ajax

      fill_in 'trainee_interaction_offer_date', with: '08/09/2013'
      fill_in 'trainee_interaction_offer_title', with: 'CNC Machinist'
      click_on 'Update'
      wait_for_ajax

      expect(page).to have_text 'Offer'

      # change from interview to hire
      myid = page.find("#trainees_Interview").first(:xpath, "//*[contains(@id, 'edit_trainee_interaction_')]")[:id]
      click_link myid

      wait_for_ajax
      fill_in 'trainee_interaction_start_date', with: '10/09/2013'
      fill_in 'trainee_interaction_hire_title', with: 'CNC Machinist'
      fill_in 'trainee_interaction_hire_salary', with: '13.50'
      click_on 'Update'
      wait_for_ajax

      expect(page).to have_text 'Hired'
      expect(page).to_not have_text 'Interested'

      # now lets test the modal popup details
      myid = page.find("#trainees_Offer").first(:xpath, "//*[contains(@id, 'show_trainee_interaction_link')]")[:id]
      click_link myid

      wait_for_ajax


      expect(page.find_by_id('modal_ti_details')).to have_text get_employers.first.name
      expect(page.find_by_id('modal_ti_details')).to have_text 'Offer Title:'
      expect(page.find_by_id('modal_ti_details')).to have_text 'Offer Date:'

      click_button 'modal_close'

      employer = get_employers.first
      ti = employer.trainee_interactions.first
      trainee = ti.trainee
      trainee_name = trainee.name
      expect(page).to have_text trainee_name

      click_link("destroy_trainee_interaction_#{ti.id}_link")
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text trainee_name


    end
  end

end
