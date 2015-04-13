require 'rails_helper'

describe 'admin user selects a grant to work on' do
  before(:each) do
    Account.current_id = 1
    create(:grant, name: 'Mega Grant')

    signin_admin
  end

  it 'selects grant' do
    expect(page).to have_text 'Your working context is set to'

    select 'Mega Grant', from: ' Change Current Grant To'
    click_on 'Set Grant'

    expect(page).to have_text 'Program Summary'
  end
end
