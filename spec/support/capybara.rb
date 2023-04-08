require 'capybara'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'

# Capybara.server_port = 7171
Capybara.server_port = 7171 + ENV['TEST_ENV_NUMBER'].to_i

Capybara.server do |app, port|
  require 'rack/handler/puma'
  Rack::Handler::Puma.run(app, Port: port, Threads: '0:4')
end
Capybara.save_path = ENV['CAPYBARA_PAGE_PATH'] || 'public/tmp'

JS_DRIVER = :selenium_chrome_headless
Capybara.default_driver = :rack_test
Capybara.javascript_driver = JS_DRIVER
Capybara.default_max_wait_time = 2

RSpec.configure do |config|
  config.before(:each) do |example|
    Capybara.current_driver = JS_DRIVER if example.metadata[:js]
    Capybara.current_driver = :selenium if example.metadata[:selenium]
    Capybara.current_driver = :selenium_chrome if example.metadata[:selenium_chrome]
  end

  config.after(:each) do
    Capybara.use_default_driver
  end
end

def wait_for_ajax
  counter = 0
  while page.evaluate_script('$.active').to_i > 0
    counter += 1
    sleep(0.1)
    fail 'AJAX request took longer than 5 seconds.' if counter >= 50
  end
end

def maximize_window
  # page.driver.browser.manage.window.resize_to(1200, 1000)
  # page.driver.browser.manage().window().maximize()
end
