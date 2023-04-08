# frozen_string_literal: true

# Support for Rspec / Capybara subdomain integration testing
# Make sure this file is required by spec_helper.rb
# (e.g. save as spec/support/subdomains.rb)
# refer to https://gist.github.com/turadg/5399790

def switch_to_subdomain(subdomain)
  # lvh.me always resolves to 127.0.0.1
  # hostname = subdomain ? "#{subdomain}.localhost.com" : 'localhost.com'
  hostname = subdomain ? "#{subdomain}.lvh.me" : 'lvh.me'
  Capybara.app_host = "http://#{hostname}"
end

def switch_to_main_domain
  switch_to_subdomain 'www'
end

def switch_to_demo_domain
  switch_to_subdomain 'demo'
end

def switch_to_applicants_domain
  switch_to_subdomain 'apple'
end

def switch_to_auto_leads_domain
  switch_to_subdomain 'njit'
end

def switch_to_api_domain
  switch_to_subdomain 'operoapi'
end

RSpec.configure do |_config|
  switch_to_main_domain
end

Capybara.configure do |config|
  config.always_include_port = true
end
