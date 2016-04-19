require "resque/tasks"
require "resque/scheduler/tasks"

namespace :resque do
  task :setup do
    require 'resque'
    Resque.redis = 'localhost:6379'
  end

  task :setup_schedule => :setup do
    require 'resque-scheduler'
    Resque.schedule = YAML.load_file(File.join(__dir__, '/resque_scheduler.yml'))
  end
  task :scheduler => :setup_schedule
end
