require 'rails_helper'

describe 'klass category' do
  before :each do
    signin_applicants_director
  end
  after :each do
    signout
  end

  it 'adds and deletes klass category', js: true do
    maximize_window

    click_on 'Settings'
    click_on 'Class Categories'
    click_on 'New'

    fill_in 'Code', with: 'WS'
    fill_in 'Description', with: 'Workshop'

    click_button 'Add'

    expect(page).to have_text('Class Category created successfully.')

    visit '/klass_categories'

    expect(page).to have_text('WS')

    kc = KlassCategory.unscoped.where(code: 'WS').first
    id = "destroy_klass_category_#{kc.id}_link"
    click_link id
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to_not have_text('WS')
  end
end
