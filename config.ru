# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

worker_cmd = 'bundle exec shoryuken -R'
pid = Process.spawn worker_cmd

p "============== Shoryuken process started with pid: [#{pid}] ================="

# Action Cable requires that all classes are loaded in advance
Rails.application.eager_load!

run Rails.application

