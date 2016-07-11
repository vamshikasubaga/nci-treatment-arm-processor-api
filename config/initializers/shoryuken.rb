
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

  module Logging
    def self.initialize_logger(log_target = STDOUT)
      @logger = Logger.new(log_target, 50, 1.megabyte)
      @logger.level = Logger::INFO
      @logger.formatter = Pretty.new
      @logger
    end
  end
end

Shoryuken.configure_server do | config |

end

logger = Shoryuken::Logging.initialize_logger("#{Rails.root}/log/shoryuken.log")
logger.level = Logger::DEBUG
Rails.logger = logger
