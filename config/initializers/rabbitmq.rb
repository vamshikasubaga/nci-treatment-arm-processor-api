require 'bunny'

class Publisher

  attr_accessor :connection, :channel

  def self.publish(queue_name, message = {})
    message_queue = channel.queue(queue_name, :durable => true)
    message_queue.publish(message.to_json, :routing_key => message_queue.name, :persistent => true)
  end

  def self.channel
    @channel ||= self.connection.create_channel
  end

  def self.connection
    @connection ||= Bunny.new(:host => "localhost", :vhost => "/", :user => "guest", :password => "guest").tap {|c| c.start }
  end

end

