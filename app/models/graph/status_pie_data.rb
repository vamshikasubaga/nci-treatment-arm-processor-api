class StatusPieData
  include Aws::Record
  include Aws::Record::RecordClassMethods
  include Aws::Record::ItemOperations::ItemOperationsClassMethods

  set_table_name "#{Rails.configuration.environment.fetch('table_prefix')}_#{self.name.underscore}_#{Rails.env}"

  string_attr :id, hash_key: true
  list_attr :status_array

end