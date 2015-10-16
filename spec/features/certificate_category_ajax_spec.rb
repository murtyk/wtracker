require 'rails_helper'

describe 'certificate category' do
  before :each do
    signin_applicants_director
  end
  after :each do
    signout
  end

  it 'adds and deletes certificate category', js: true do
    maximize_window

    click_on 'Settings'
    click_on 'Certificate Categories'
    click_on 'New'

    fill_in 'Code', with: '777'
    fill_in 'Name', with: 'PMP'

    click_button 'Add'

    expect(page).to have_text('Certificate Category created successfully.')

    visit '/certificate_categories'

    expect(page).to have_text('777')

    kc = CertificateCategory.unscoped.where(code: '777').first
    id = "destroy_certificate_category_#{kc.id}_link"
    click_link id
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to_not have_text('777')
  end
end
