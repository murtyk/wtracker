# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'shoulda/matchers'
# require 'rspec/autorun'
require 'support/subdomains'

# require 'simplecov'
# require 'simplecov-csv'
# require 'headless'
require 'rspec/retry'
# require 'webmock/rspec'
# WebMock.allow_net_connect!

# SimpleCov.formatter = SimpleCov::Formatter::CSVFormatter
# SimpleCov.coverage_dir(ENV['COVERAGE_REPORTS'] || 'coverage')

# SimpleCov.start do
#   add_group 'Models', '/app/models/'
#   add_group 'Controllers', '/app/controllers/'
#   add_group 'Factories', '/app/factories/'
#   add_group 'Services', '/app/services/'
#   add_group 'Reports', '/app/reports/'
#   add_group 'Imports', '/app/imports/'
#   add_group 'Helpers', '/app/helpers/'
#   add_group 'Policies', '/app/policies/'
#   add_group 'Views', '/app/views/'
# end

# require 'codecov'
# SimpleCov.formatter = SimpleCov::Formatter::Codecov

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

require 'selenium-webdriver'

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
  config.order = 'random'
  # config.order = "default"

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
  config.include(ReportsHelper)
  config.include(ImportsHelper)
  config.include Request::JsonHelpers,    type: :controller
  config.include Request::HeadersHelpers, type: :controller

  config.include FactoryBot::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller

  # config.raise_errors_for_deprecations!

  # config.filter_run_excluding js: true

  config.before(:suite) do
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
    allow(GeoServices).to receive(:latlong).and_return([40, -70])
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.verbose_retry = true # show retry status in spec process

  config.reporter.register_listener SpecListener.new, :example_passed
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Capybara::Screenshot.autosave_on_failure = false

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.deliveries = []
