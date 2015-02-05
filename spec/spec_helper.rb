require 'simplecov'
require 'headless'
require 'rspec/retry'

SimpleCov.start do
  add_group 'Models', '/app/models/'
  add_group 'Controllers', '/app/controllers/'
  add_group 'Factories', '/app/factories/'
  add_group 'Services', '/app/services/'
  add_group 'Reports', '/app/reports/'
  add_group 'Helpers', '/app/helpers/'
  add_group 'Policies', '/app/policies/'
  add_group 'Views', '/app/views/'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
require 'capybara/rspec'
require 'support/subdomains.rb'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'
# require 'webmock/rspec'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# WebMock.allow_net_connect!

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  # config.order = "default"

  Capybara.server_port = 7171 + ENV['TEST_ENV_NUMBER'].to_i
  # Capybara.use_own_port = true
  # Capybara.app_host = "http://www.localhost.com:7171"
  config.include Capybara::DSL
  config.include Rails.application.routes.url_helpers
  # config.include RSpec::Rails::IntegrationExampleGroup, example_group: { file_path: /\bspec\/features\// }
  config.include(UserHelper)
  config.include(LinksHelper)
  config.include(TraineesHelper)
  config.include(EmployersHelper)
  config.include(KlassesHelper)
  config.include(KlassTraineesHelper)
  config.include(AutoLeadsHelper)
  config.include(ApplicantsHelper)

  config.include FactoryGirl::Syntax::Methods
  # config.raise_errors_for_deprecations!

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Devise::TestHelpers, type: :controller

  config.verbose_retry = true # show retry status in spec process

  puts ENV['TEST_ENV_NUMBER']
  display =  100 + ENV['TEST_ENV_NUMBER'].to_i
  headless = Headless.new(display: display)

  config.before(:each, js: true) do |ex|
    headless.start unless ex.metadata[:noheadless]
  end

  config.after(:each, js: true) do |ex|
   headless.stop unless ex.metadata[:noheadless]
  end

  at_exit do
    headless.destroy unless ENV['TEST_ENV_NUMBER'].to_i > 0
  end

end
