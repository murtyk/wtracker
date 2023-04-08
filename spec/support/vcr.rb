require 'mechanize'
require 'webmock/rspec'
WebMock.disable_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'vcr')
  c.hook_into :webmock # or :fakeweb
  c.default_cassette_options = { record: :new_episodes }
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true

  c.filter_sensitive_data('<simplyhired_auth>') do
    ENV['SH_AUTH']
  end

  c.filter_sensitive_data('<simplyhired_jbd>') do
    ENV['JBD']
  end

  c.filter_sensitive_data('<simplyhired_pshid>') do
    ENV['PSHID']
  end

  c.filter_sensitive_data('<googleapis_key>') do
    ENV['GOOGLE_KEY']
  end

  c.filter_sensitive_data('<indeed_publisher>') do
    ENV['PUBLISHER']
  end
end
