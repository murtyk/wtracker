# This file is used by Rack-based servers to start the application.

# --- Start of unicorn worker killer code ---

if ENV['RAILS_ENV'] == 'production' || ENV['RAILS_ENV'] == 'staging'
  require 'unicorn/worker_killer'

  max_request_min =  500
  max_request_max =  600

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max

  dyno_size = ENV['RAILS_ENV'] == 'production' ? 2 : 1

  oom_min = dyno_size * (230) * (1024**2)
  oom_max = dyno_size * (250) * (1024**2)

  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

# --- End of unicorn worker killer code ---

if ENV['RAILS_ENV'] == 'production'
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|

    hex_username = ::Digest::SHA256.hexdigest(username)
    dj_username = ::Digest::SHA256.hexdigest(ENV['DJ_USERNAME'])

    hex_password = ::Digest::SHA256.hexdigest(password)
    dj_password = ::Digest::SHA256.hexdigest(ENV['DJ_PASSWORD'])

    ActiveSupport::SecurityUtils.secure_compare(hex_username, dj_username) &&
      ActiveSupport::SecurityUtils.secure_compare(hex_password, dj_password)
  end
end

require ::File.expand_path('../config/environment',  __FILE__)
run WTracker::Application


