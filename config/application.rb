require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WTracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    # config.autoloader = :zeitwerk

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

# auto load lib
Rails.application.configure do
  config.autoload_paths += [Rails.root.join('lib')]
  config.autoload_paths += Dir["#{config.root}/lib/**/"]

  config.eager_load_paths += [Rails.root.join('lib')]
  config.eager_load_paths += Dir["#{config.root}/lib/**/"]

  config.before_configuration do
    env_file = File.join(Rails.root, 'config', 'local_env.yml')

    if File.exist?(env_file)
      YAML.safe_load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value.to_s
      end
    end
  end

  config.active_record.yaml_column_permitted_classes = [
    ActiveSupport::HashWithIndifferentAccess,
    OpenStruct,
    Symbol
  ]
end
