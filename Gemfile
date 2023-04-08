# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.9'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bson_ext'
gem 'mongo'
gem 'mongoid'
gem 'pg', '~> 0.20'
gem 'puma', '~> 5.0'
gem 'rails', '~> 5.0.2'

gem 'attr_encrypted', '1.3.5'
gem 'aws-sdk-s3', '~> 1'
gem 'aws-sdk-ses', '~> 1'
gem 'devise', '~> 4.4.0'
gem 'draper'
gem 'fusion_tables', '0.4.1'
gem 'geocoder', '1.4.4'
gem 'gmaps4rails', '1.5.6'
gem 'httparty'
gem 'mechanize', '2.7.5'
gem 'rest-client', '2.0.2'
gem 'roo', '1.13.2'
gem 'rubyzip', '1.0.0'
gem 'simple_form', '3.4.0'
gem 'zip-zip'

gem 'fuzzy-string-match_pure', '0.9.5'

gem 'bootstrap-will_paginate', '0.0.6'
gem 'will_paginate', '3.1.5'

gem 'clockwork'
gem 'dalli', '2.6.4'
gem 'delayed_job_active_record', '4.1.2'
gem 'humanizer'
gem 'icalendar', '1.4.3'
gem 'memcachier', '0.0.2'
gem 'pg_search'
gem 'pundit', '1.1.0'
gem 'ransack'

gem 'bootstrap-datepicker-rails', '1.1.1.6'
gem 'bootstrap-sass', '~> 2.3.0.0'
gem 'coffee-rails', '~> 4.2'
gem 'font-awesome-sass-rails', '3.0.2.2'
gem 'sass-rails', '~> 5.0'

gem 'uglifier', '>= 1.3.0'
# gem 'jquery-ui-rails'

gem 'google-api-client'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rubocop', require: false

  # rspec-rails is required here to get the mailer previews work
  gem 'rails-controller-testing'
  gem 'rspec-rails', '3.5.2'
  gem 'shoulda-matchers', '4.5.1'
end

group :development do
  gem 'rack-mini-profiler'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-retry'
  # gem 'poltergeist'
  # gem 'phantomjs', :require => 'phantomjs/poltergeist'

  gem 'selenium-webdriver'
  # gem 'webdrivers'
  # gem 'capybara-selenium'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'faker'
  gem 'guard-rspec'
  gem 'headless'
  gem 'launchy'
  gem 'vcr'
  gem 'webmock'

  # gem 'simplecov' #, require: false
  # gem 'simplecov-csv'
  # gem 'codecov', :require => false, :group => :test

  gem 'rspec_junit_formatter'
  gem 'shog'
end

gem 'jquery.fileupload-rails'
gem 'jquery-rails', '4.3.1'
gem 'parallel_tests', group: :development

gem 'axlsx', '2.0.1'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby'

# To use Jbuilder templates for JSON
gem 'jbuilder', '~> 2.5'
