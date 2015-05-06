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
  it 'full url with js', js: true do
    visit 'http://www.localhost.com:7171/login'
    expect(page).to have_text 'Remember Me'
  end
end
