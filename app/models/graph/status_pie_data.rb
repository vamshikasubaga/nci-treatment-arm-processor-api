class StatusPieData
  include Aws::Record

  set_table_name "#{ENV['table_prefix']}_#{self.name.underscore}_#{Rails.env}"

  string_attr :id, hash_key: true
  list_attr :status_array

end