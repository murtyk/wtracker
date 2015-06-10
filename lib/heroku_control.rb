require 'platform-api'

# Simple class to interact with Heroku's platform API, allowing
# you to start and stop worker dynos.
class HerokuControl

  API_TOKEN     = ENV['HEROKU_OAUTH_TOKEN'] || 'b951c3f4-f9fd-42f1-bb50-511515e4691d'
  WORKERS_COUNT = ENV['TAPO_WORKERS_COUNT'] || 1
  WORKERS_NAME_PREFIX = ENV['TAPO_WORKERS_PREFIX'] || 'tapoworker'

  def self.heroku
    @heroku ||= PlatformAPI.connect_oauth(API_TOKEN)
  end

  # Spin up one worker for each tapo worker (auto job leads)
  def self.auto_leads_workers_up
    set_auto_leads_workers(1)
  end

  # Spin down workers for tapo worker app
  def self.auto_leads_workers_down
    sleep 90
    set_auto_leads_workers(0)
  end

  def self.set_auto_leads_workers(quantity)
    1.upto(WORKERS_COUNT.to_i) do |n|
      app_name = WORKERS_NAME_PREFIX + '-' + n.to_s
      self.worker_set_quantity(app_name, quantity)
    end
  end

  def self.worker_set_quantity(app_name, quantity)
    heroku.formation.update(app_name, 'worker', {"quantity" => quantity.to_s})
  end
end