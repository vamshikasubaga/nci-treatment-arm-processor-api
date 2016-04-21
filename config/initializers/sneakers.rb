require 'sneakers'

Sneakers.configure(:heartbeat => 20,
                   :amqp => 'amqp://guest:guest@192.168.99.100:5672',
                   :vhost => '/')
