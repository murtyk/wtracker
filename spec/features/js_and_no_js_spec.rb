require 'rails_helper'
describe 'signin page' do
  it 'no js' do
    visit root_path
    expect(page).to have_text 'Remember Me'
  end
  it 'with js', js: true do
    visit root_path
    expect(page).to have_text 'Remember Me'
  end
end
