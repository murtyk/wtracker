require 'rails_helper'

def fill_in_fields
  fill_in 'Status', with: 'Some Status'
  select 'Accept', from: 'Action'
  fill_in 'Email subject', with: 'Hello'
  fill_in 'Email body', with: 'Congrats! You are accepted'
end
describe 'employment status' do
  before :each do
    signin_applicants_director
  end
  after :each do
    signout
  end
  it 'adds employment status' do
    click_on 'Settings'
    click_on 'Employment Status'
    click_on 'New'

    fill_in_fields
    click_button 'Add'

    expect(page).to have_text('Employment Status was successfully created.')

    click_on 'Settings'
    click_on 'Employment Status'

    expect(page).to have_text('Some Status')
  end
  it 'adds and deletes employment status', js: true do
    visit '/employment_statuses/new'

    fill_in_fields
    click_button 'Add'

    expect(page).to have_text('Employment Status was successfully created.')

    visit '/employment_statuses'

    expect(page).to have_text('Some Status')

    es = EmploymentStatus.unscoped.where(status: 'Some Status').first
    id = "destroy_employment_status_#{es.id}_link"
    AlertConfirmer.accept_confirm_from do
      click_link id

    end
    wait_for_ajax
    expect(page).to_not have_text('Some Status')
  end
end
