require 'sneakers'

Sneakers.configure(:heartbeat => 20,
                   :amqp => 'amqp://guest:guest@localhost:5672',
                   :vhost => '/')
