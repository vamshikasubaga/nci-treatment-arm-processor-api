logger = Shoryuken::Logging.initialize_logger("#{Rails.root}/log/shoryuken.log")
logger.level = Logger::DEBUG
Rails.logger = logger

Shoryuken.options do | config |

end