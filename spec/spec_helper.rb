# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'shoulda/matchers'
require 'support/subdomains'
require 'rspec/retry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false

  config.order = 'random'
  # config.order = "default"

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

  config.filter_run_excluding(skip_on_ci: true) if ENV['RAILS_CI']

  config.verbose_retry = true # show retry status in spec process

  config.reporter.register_listener SpecListener.new, :example_passed

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :chrome_headless
  end
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
