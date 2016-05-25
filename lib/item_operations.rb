
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

    module ItemOperations
      module ItemOperationsClassMethods
        alias_method :original_find, :find

        def find(opts)
          if (!self.table_exists?)
                migration = Aws::Record::TableMigration.new(self)
                migration.create!(provisioned_throughput: { read_capacity_units: 5, write_capacity_units: 5 })
                migration.wait_until_available
          end
          original_find(opts)
        end

      end
    end

    module Query
      module QueryClassMethods
        alias_method :orginal_scan, :scan

        def scan(opts = {})
          if (!self.table_exists?)
            migration = Aws::Record::TableMigration.new(self)
            migration.create!(provisioned_throughput: { read_capacity_units: 5, write_capacity_units: 5 })
            migration.wait_until_available
          end
          orginal_scan(opts)
        end
      end
    end
  end
end