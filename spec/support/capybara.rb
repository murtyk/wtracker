require "capybara/rails"
require 'capybara/rspec'

# Capybara.server_port = 7171
Capybara.server_port = 7171 + ENV['TEST_ENV_NUMBER'].to_i

Capybara.server do |app, port|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, Port: port)
end
Capybara.save_and_open_page_path = "public/tmp"

def wait_for_ajax
  counter = 0
  while page.execute_script("return $.active").to_i > 0
    counter += 1
    sleep(0.1)
    raise "AJAX request took longer than 5 seconds." if counter >= 50
  end
end

def maximize_window
  page.driver.browser.manage.window.resize_to(1200,1000)
  # page.driver.browser.manage().window().maximize()
end