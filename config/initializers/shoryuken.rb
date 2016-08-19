
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
  Shoryuken.logger.info "====== Configuring SQS connection ======"

   region = ENV['aws_region']
   Shoryuken.logger.info "====== region: #{ENV['aws_region']} ======"

   end_point = "https://sqs.#{region}.amazonaws.com"
   Shoryuken.logger.info "====== end point: #{end_point} ======"

   @queue_name = ENV['queue_name']
   Shoryuken.logger.info "====== queue_name: #{@queue_name} ======"

   access_key = Rails.application.secrets.aws_access_key_id
   aws_secret_access_key = Rails.application.secrets.aws_secret_access_key

   creds = Aws::Credentials.new(access_key, aws_secret_access_key)

   @client ||= Aws::SQS::Client.new(endpoint: end_point, region: region, credentials: creds)

   begin
     queue = Shoryuken::Queue.new(@client, @queue_name)
     Shoryuken.logger.info "====== Queue [#{@queue_name}] Connection test was successful ======"
   rescue Aws::SQS::Errors::NonExistentQueue => e
     Shoryuken.logger.info "====== SQS queue [#{@queue_name}] doesn't exist. Error: #{e.message} ======"
     Shoryuken.logger.info "====== Creating queue [#{@queue_name}] ======"
     @client.create_queue({:queue_name => @queue_name})
     Shoryuken.logger.info "====== Created queue [#{@queue_name}] ======"
   end
end

logger = Shoryuken::Logging.initialize_logger("#{Rails.root}/log/shoryuken.log")
logger.level = Logger::DEBUG
Rails.logger = logger
