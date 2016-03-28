require 'rails_helper'

describe 'Assessments' do
  before :each do
    signin_director
    @assessment_name = Faker::Lorem.words(2).join("_")
    visit('/assessments')
  end

  it 'can list, add and delete', js: true do
    click_on 'New Assessment'
    wait_for_ajax
    fill_in 'assessment_name', with: @assessment_name
    click_on 'Add'
    wait_for_ajax
    expect(page).to have_text @assessment_name

    assessment_id = Assessment.unscoped.pluck(:id).sort.last
    id = "destroy_assessment_#{assessment_id}_link"

    AlertConfirmer.accept_confirm_from do
      click_button(id)
    end

    wait_for_ajax

    expect(page).to_not have_text @assessment_name
  end
end
