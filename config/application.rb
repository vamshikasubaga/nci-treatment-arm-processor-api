require File.expand_path('../boot', __FILE__)
require File.expand_path('../version', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NciTreatmentArmProcessorApi
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += Dir[Rails.root.join('app', 'workers')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '*')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'treatment_arm', '{*/}')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'treatment_arm', 'variants', '{*/}')]

    config.logger = Logger.new(STDOUT)
    config.logger.formatter = Proc.new { |severity, datetime, _progname, msg| "[#{datetime.strftime("%B %d %H:%M:%S")}] [#{$$}] [#{severity}] [#{Rails.application.class.parent_name}], #{msg}\n"}

    config.after_initialize do
      config.logger.extend ActiveSupport::Logger.broadcast(SlackLogger.logger)
    end

    config.environment = Rails.application.config_for(:environment)

    # config.before_configuration do
    #   env_file = Rails.root.join('config', 'environment.yml')
    #   if File.exists?(env_file)
    #     YAML.load_file(env_file)[Rails.env].each do |key, value|
    #       ENV[key.to_s] = value
    #     end
    #   end
    # end
    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    # config.active_job.queue_adapter = :shoryuken
  end
end
