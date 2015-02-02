require 'rails_helper'

describe "navigator user selects a grant to work on", js: true do

  it "select one" do
    signin_opero_admin
    page.driver.browser.manage.window.resize_to(1100,1000)
    expect(page).to have_text 'Accounts'
    click_on 'PAWF Org'
    click_on 'New Grant'
    fill_in 'Name', with: 'Mega Grant'
    fill_in 'Start date', with: '01/01/2014'
    fill_in 'End date', with: '12/01/2015'
    click_on 'Add'
    expect(page).to have_text 'Grant was successfully created.'
    page.find(:xpath, "//a[@href='/admins/sign_out']").click

    # now admin signs in and:
    # adds a navigator to existing class (CNC 101) in existing grant (Big Grant)
    # switches to Mega Grant, creates program and class, and assigns the navigator to class
    signin_admin
    expect(page).to have_text 'Your working context is set to'

    select 'Big Grant', from: 'Change Current Grant To'
    click_on 'Set Grant'
    visit '/klasses'
    click_on 'CNC 101'
    click_link 'new_klass_navigator_link'
    select('Melinda Peters', from: 'klass_navigator_user_id')
    click_on 'Add'
    expect(page).to have_text 'Melinda Peters'

    click_on 'Grants'
    click_on 'List'
    expect(page).to have_text 'Big Grant'
    expect(page).to have_text 'Mega Grant'

    click_on 'Grants'
    click_on 'Change Current Grant'

    select 'Mega Grant', from: 'Change Current Grant To'
    click_on 'Set Grant'
    expect(page).to have_text 'Program Summary'

    # now create a program and klass

    href_link('programs').click
    href_link('programs/new').click
    fill_in 'Name', with: 'Mega Program'
    fill_in 'Hours', with: '300'
    select('health', from: 'Sector')
    click_button 'Add'
    expect(page).to have_text 'Mega Program'

    visit '/klasses'
    click_on 'New'
    fill_in 'Name', with: 'Mega Class'
    click_on 'Save'

    visit '/klasses'
    click_on 'Mega Class'

    click_link 'new_klass_navigator_link'
    select('Melinda Peters', from: 'klass_navigator_user_id')
    click_on 'Add'
    expect(page).to have_text 'Melinda Peters'

    signout
    signin_navigator
    select 'Mega Grant', from: 'Change Current Grant To'
    click_on 'Set Grant'

    signout

    # de-assign navigator to class
    signin_admin
    expect(page).to have_text 'Your working context is set to'

    select 'Big Grant', from: 'Change Current Grant To'
    click_on 'Set Grant'
    visit '/klasses'
    click_on 'CNC 101'

    expect(page).to have_text 'Melinda Peters'
    Account.current_id = 1
    Grant.current_id = 1
    klass = Klass.where(name: 'CNC 101').first
    klass_navigator = klass.klass_navigators.first
    id = "destroy_klass_navigator_#{klass_navigator.id}_link"
    click_link id
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to_not have_text 'Melinda Peters'
    signout

    # change Mega Grant name to something else which is uniq
    signin_opero_admin
    click_on 'PAWF Org'

    grant = Grant.unscoped.where(name: 'Mega Grant').first
    id = "edit_grant_#{grant.id}_link"
    click_link id
    fill_in 'Name', with: 'Closed Grant'
    select 'Closed', from: 'Status'
    click_button 'Update'

    page.find(:xpath, "//a[@href='/admins/sign_out']").click
  end
end
