require 'rails_helper'

describe 'Report' do
  describe 'Trainees Placed' do
    before :each do
      signin_admin
      destroy_trainees
    end

    after :each do
      destroy_trainees
    end

    it 'shows the trainees updated on class page', js: true do
      trainee_ids = create_trainees(1)
      klass_trainee_ids = get_klass_trainee_ids(trainee_ids)
      klass = get_an_existing_klass

      click_link(klass.name, match: :first)

      wait_for_ajax

      click_link "edit_klass_trainee_#{klass_trainee_ids[0]}_link"
      sleep 0.2
      select KlassTrainee::STATUSES[4], from: 'klass_trainee_status'
      wait_for_ajax
      fill_in 'klass_trainee_employer_name', with: 'W'
      click_on 'Find'
      wait_for_ajax

      start_date = '02/22/2014'
      hire_title = 'Good Title'
      hire_salary = '33'

      fill_in 'Start date', with: start_date
      fill_in 'Hire title', with: hire_title
      fill_in 'Hire salary', with: hire_salary
      click_on 'Update'

      visit_report Report::TRAINEES_PLACED
      select 'All', from: 'Class'
      click_on 'Find'

      expect(page).to have_text 'First1 Last1'
      expect(page).to have_text start_date
      expect(page).to have_text hire_title
      expect(page).to have_text hire_salary
    end

    it 'trainees updated on trainee page', js: true do
      create_trainees(1)

      click_link 'new_trainee_interaction_link'
      wait_for_ajax

      fill_in 'trainee_interaction_employer_name', with: 'W'
      click_on 'Find'
      wait_for_ajax
      click_on 'Add'
      wait_for_ajax
      ti_ids = get_trainee_interaction_ids
      click_link "edit_trainee_interaction_#{ti_ids[0]}_link"
      start_date = '02/22/2014'
      hire_title = 'Good Title'
      hire_salary = '33'

      fill_in 'Start date', with: start_date
      fill_in 'Hire title', with: hire_title
      fill_in 'Hire salary', with: hire_salary
      click_on 'Update'
      wait_for_ajax
      expect(page).to have_text 'No OJT'

      visit_report Report::TRAINEES_PLACED
      select 'All', from: 'Class'
      click_on 'Find'

      expect(page).to have_text 'First1 Last1'
      expect(page).to have_text start_date
      expect(page).to have_text hire_title
      expect(page).to have_text hire_salary
    end
  end
end
