# frozen_string_literal: true

require 'capybara'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'

Capybara.server = :puma, { Silent: true }
Capybara.server_port = 7171 + ENV['TEST_ENV_NUMBER'].to_i

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

def wait_for_ajax
  counter = 0
  while page.evaluate_script('$.active').to_i > 0
    counter += 1
    sleep(0.1)
    raise 'AJAX request took longer than 5 seconds.' if counter >= 50
  end
end

def maximize_window
  # page.driver.browser.manage.window.resize_to(1200, 1000)
  # page.driver.browser.manage().window().maximize()
end



