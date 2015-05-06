require 'rails_helper'
describe 'signin page' do
  it 'no js' do
    visit '/login'
    expect(page).to have_text 'Remember Me'
  end
  it 'with js', js: true do
    visit '/login'
    expect(page).to have_text 'Remember Me'
  end
end
