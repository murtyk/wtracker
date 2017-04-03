require 'rails_helper'

describe 'TraineeService', js: true do
  describe 'Trainee Page' do
    before :each do
      signin_admin
      destroy_trainees
      create_trainees(1)
    end
    after :each do
      destroy_trainees
    end
    it 'user adds, updates and deleted a Service' do
      click_link "trainee_#{get_trainee_ids[0]}_new_trainee_service_link"
      wait_for_ajax
      
      fill_in 'trainee_service_name', with: 'Sahu Service'
      fill_in 'trainee_service_start_date', with: '11/01/2017'
      fill_in 'trainee_service_end_date', with: '11/01/2018'
      fill_in 'account_id', with: '1'
      fill_in 'grant_id', with: '1'
      
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'Sahu Service'

      click_link "edit_trainee_service_#{get_trainee_services_ids[0]}_link"
      wait_for_ajax
      
      fill_in 'trainee_service_name', with: 'Sahu Service updated'
      fill_in 'trainee_service_start_date', with: '11/01/2017'
      fill_in 'trainee_service_end_date', with: '11/01/2018'
      fill_in 'account_id', with: '1'
      fill_in 'grant_id', with: '1'
     
      click_on 'Update'
      wait_for_ajax
      expect(page).to have_text 'Sahu Service updated'

      AlertConfirmer.accept_confirm_from do
        click_link "destroy_trainee_service_#{get_trainee_services_ids[0]}_link"

      end
      wait_for_ajax
      expect(page).to_not have_text 'Sahu Service'
    end
  end
end
