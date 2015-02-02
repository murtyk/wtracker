require 'rubygems'
require 'capybara'
require 'capybara/dsl'

# Capybara.current_driver = :selenium
# Capybara.run_server = false
# Capybara.app_host = 'http://opero.managee2e.com'

describe "Administration" do
  describe "manage accounts" do
    before(:each) do
    end
    it "lists accounts", type: :feature do
      # visit('/')
      # fill_in 'email', with: "james@mail.com"
      # fill_in 'password', with: "password"
      # click_button 'Sign in'
      # expect(page).to have_text 'Accounts'
    end
  end
end