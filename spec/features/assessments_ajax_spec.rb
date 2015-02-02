require 'rails_helper'

describe "Assessments" do
  describe 'can list, add and delete' do
    before :each do
      signin_admin
      visit('/assessments')
    end

    it 'can add assessment', js: true do
      click_on 'New Assessment'
      wait_for_ajax
      fill_in 'assessment_name', with: "Assessment1"
      click_on 'Add'
      wait_for_ajax
      expect(page).to have_text 'Assessment1'
    end

    it 'can delete assessment', js: true do
      assessment = Assessment.unscoped.where(name: 'Assessment1').first
      id = "destroy_assessment_#{assessment.id}_link"
      click_link id
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'Assessment1'
    end
  end
end