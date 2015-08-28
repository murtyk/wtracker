require 'rails_helper'

describe 'Employer and Class Interaction' do
  before :each do
    signin_admin
    destroy_employers
  end
  after :each do
    destroy_employers
  end
  it 'can create and update', js: true, noheadless: true do
    visit '/klass_interactions/new'
    wait_for_ajax
    fill_in 'Name', with: 'Company Abc Inc.'

    select('banking', from: 'Sectors')

    click_on 'Save'
    expect(page).to have_text 'Class Interaction successfully created.'

    click_on 'Expand'
    expect(page).to have_text 'Interested'

    myid = page.find('#klass_interactions')
           .first(:xpath, "//*[contains(@id, 'edit_klass_interaction')]")[:id]
    click_link myid

    select 'Confirmed', from: 'Status'
    click_on 'Update'

    wait_for_ajax
    sleep 1

    expect(page).to have_text 'Confirmed'
    expect(page).to_not have_text 'Interested'

    klass_href = page.find('#klass_interactions')
                 .first('a', "//*[contains(@href='/klasses')]")[:href]
    visit klass_href
    click_on 'Expand All'

    events = page.find('#Information_Session_events')
    expect(events).to have_text 'Confirmed'
    myid = events.first(:xpath, "//*[contains(@id, 'destroy_klass_interaction')]")[:id]
    click_link myid

    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to_not have_text 'Confirmed'
  end
end
