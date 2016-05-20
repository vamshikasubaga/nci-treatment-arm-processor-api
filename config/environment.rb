# Load the Rails application.
require File.expand_path('../application', __FILE__)

require 'hash_extension'
require 'model_serializer'
require 'item_operations'

Dir["/path/to/directory/*.rb"].each {|file| require file }

Rails.application.initialize!
