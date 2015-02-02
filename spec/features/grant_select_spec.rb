require 'rails_helper'

describe "admin user selects a grant to work on" do
  before(:each) do
    signin_opero_admin
  end

  it "select one" do
    expect(page).to have_text 'Accounts'

    click_on 'PAWF Org'

    click_on 'New Grant'

    fill_in 'Name', with: 'Mega Grant'
    fill_in 'Start date', with: '01/01/2013'
    fill_in 'End date', with: '12/01/2013'
    fill_in 'Trainee Spots', with: '100'
    fill_in 'Grant $ Amount', with: '5000000'
    click_on 'Add'
    expect(page).to have_text 'Grant was successfully created.'

    page.find(:xpath, "//a[@href='/admins/sign_out']").click

    signin_admin
    expect(page).to have_text 'Your working context is set to'

    select 'Mega Grant', from: ' Change Current Grant To'
    click_on 'Set Grant'

    expect(page).to have_text 'Program Summary'

    Account.current_id = 1
    grant = Grant.where(name: 'Mega Grant').first
    grant.destroy
  end
end
