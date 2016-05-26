
module Aws
  module Record

    module RecordClassMethods
      alias_method :original_configure_client, :configure_client
      def configure_client(opts = {})
        opts = {
            endpoint: ENV['aws_dynamo_endpoint'],
            region: ENV['aws_region']
        }
        original_configure_client(opts)
      end
    end
  end
end