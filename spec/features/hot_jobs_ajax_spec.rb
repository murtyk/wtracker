require 'rails_helper'

RSpec.feature 'HotJobs', type: :feature, js: true do
  before :each do
    signin_admin
  end
  after :each do
    signout
  end
  it 'creates, lists and destroys hot job' do
    visit('/hot_jobs/new')
    maximize_window

    title = 'This is an awesome title for the job'

    fill_in 'Title', with: title
    fill_in 'Description', with: 'Job description is very interesting'
    select 'Wawa', from: 'Employer'
    click_on 'Add'
    expect(page).to have_text 'HotJob was successfully created.'
    expect(page).to have_text Date.today.to_s

    visit '/hot_jobs'
    expect(page).to have_text title.truncate(30)

    Account.current_id = 1
    hot_job = HotJob.first
    link_id = "destroy_hot_job_#{hot_job.id}_link"

    click_link link_id
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax

    expect(page).to_not have_text title.truncate(30)
  end
end
