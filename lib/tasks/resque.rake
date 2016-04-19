require "resque/tasks"
require "resque/scheduler/tasks"
# require "resque-scheduler/task"

namespace :resque do
  task :setup do
    require 'resque'
    Resque.redis = 'localhost:6379'
  end

  task :setup_schedule => :setup do
    require 'resque-scheduler'
    # Resque.schedule = YAML.load_file('your_resque_schedule.yml')
  end

  task :scheduler => :setup_schedule
end





# task "resque:setup" => :environment do
  # Resque.before_fork = Proc.new {
  #   ActiveRecord::Base.establish_connection
  #
  #   # Open the new separate log file
  #   logfile = File.open(File.join(Rails.root, 'log', 'resque.log'), 'a')
  #
  #   # Activate file synchronization
  #   logfile.sync = true
  #
  #   # Create a new buffered logger
  #   Resque.logger = ActiveSupport::BufferedLogger.new(logfile)
  #   Resque.logger.level = Logger::INFO
  #   Resque.logger.info "Resque Logger Initialized!"
  # }
# end