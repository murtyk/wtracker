source 'https://rubygems.org'

# gem 'rails', github: 'rails/rails', ref: '968c581ea34b5236af14805e6a77913b1cb36238', branch: '4-1-stable'
group :production, :staging, :integration do
  ruby ENV['CUSTOM_RUBY_VERSION'] || '2.2.0'
end

gem 'rails', '4.2'
gem 'protected_attributes', '1.0.7'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# gem 'bootstrap-sass', '~> 2.1.0.0' #trying new one

group :development, :test do
  gem "thin"
end
group :production, :staging, :integration do
  gem 'unicorn', '4.8.3'
  gem 'unicorn-worker-killer'
  gem 'rails_12factor', '0.0.2'
end

gem 'pg'
gem 'mongo'
gem 'bson_ext'
gem 'mongoid', github: 'mongoid/mongoid'

gem 'attr_encrypted', '1.3.3'
gem 'draper', '1.3.1'
gem 'simple_form', '~> 3.1.0'
gem 'devise', '~> 3.4.1'
gem 'gmaps4rails', '1.5.6'
gem 'fusion_tables', '0.4.1'
gem "zip-zip", "~> 0.2"
gem 'rubyzip', '1.0.0'
gem 'roo', '1.12.1'
gem 'geocoder', '1.2.6'
# gem 'google_places', '0.16.0'
gem 'mechanize', '~> 2.5.1'
# gem 'ox', '2.0.0'
gem 'httparty', '0.12.0'
gem 'rest-client', '1.6.7'
gem 'aws-sdk', '1.33.0'
gem 'fuzzy-string-match_pure', '0.9.5'

gem 'will_paginate', '3.0.3'
gem 'bootstrap-will_paginate', '0.0.6'

gem 'pundit', '0.2.1'
gem 'newrelic_rpm'
gem 'memcachier', '0.0.2'
gem 'dalli', '2.6.4'
gem 'icalendar', '1.4.3'
gem 'humanizer'
gem 'ransack', github: 'activerecord-hackery/ransack', branch: 'rails-4.2'

gem 'delayed_job_active_record'
gem 'clockwork'

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails',   '~> 4.0.1'
gem 'bootstrap-sass', '~> 2.3.0.0'
gem 'bootstrap-datepicker-rails', '1.1.1.6'
gem 'font-awesome-sass-rails', '3.0.2.2'
gem 'coffee-rails', '~> 4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '1.2.3'
  # gem 'jquery-ui-rails'

group :development do
  gem 'rack-mini-profiler'
  gem 'web-console', '~> 2.0'
end

group :test, :development do
  gem 'byebug'
  # gem 'debugger'
  # gem 'wdm', :platforms => [:mswin, :mingw], :require => false
end

gem 'quiet_assets', group: :development

group :test do
  gem 'rspec-rails', '~> 3.0.1'
  gem 'rspec-retry', '0.3.0'
  gem 'factory_girl_rails'
  gem 'selenium-webdriver', '2.43.0'
  gem 'headless', '1.0.2'
  gem 'capybara', '~> 2.4.1'
  gem 'capybara-screenshot'
  # gem "capybara-webkit"
  gem 'faker', '1.0.1'
  gem 'guard-rspec', '~> 4.2.10'
  gem 'shoulda'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'webmock', '1.11.0'
  gem 'vcr', '2.9.2'

  gem 'simplecov', require: false
end
gem "parallel_tests", group: :development
gem 'jquery-rails', '4.0.3'
gem "jquery.fileupload-rails", '1.11.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
