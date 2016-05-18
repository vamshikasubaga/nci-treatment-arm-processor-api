logger = Shoryuken::Logging.initialize_logger("#{Rails.root}/log/shoryuken.log")
logger.level = Logger::DEBUG
Rails.logger = logger

module Shoryuken
  def self.options
    @options = {
        concurrency: ENV['shoryuken_concurrency'].to_i,
        queues: [ENV['queue_name']],
        aws: {access_key_id: Rails.application.secrets.aws_access_key_id,
              secret_access_key: Rails.application.secrets.aws_secret_access_key,
              region: ENV['aws_region']
        },
        delay: ENV['shoryuken_delay'].to_i,
        timeout: 8,
        lifecycle_events: {
            startup: [],
            quiet: [],
            shutdown: [],
        }
    }
  end
end

Shoryuken.configure_server do | config |

end
