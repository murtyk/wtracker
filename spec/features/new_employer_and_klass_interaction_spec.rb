require 'rails_helper'

describe "Employer and Class Interaction" do

  before :each do
    signin_admin
  end
  after :each do
    destroy_employers
  end
  it "can create", js: true do
    visit '/klass_interactions/new'
    wait_for_ajax
    fill_in 'Name', with: 'Company Abc Inc.'
    fill_in 'Source', with: 'test'

    select('banking', from: 'Sectors')

    click_on 'Save'
    expect(page).to have_text 'Class Interaction successfully created.'

    click_on 'Expand'
    expect(page).to have_text 'Interested'
  end

end
