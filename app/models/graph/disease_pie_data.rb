class DiseasePieData
  include Aws::Record

  set_table_name "#{Rails.configuration.environment.fetch('table_prefix')}_#{self.name.underscore}_#{Rails.env}"

  string_attr :id, hash_key: true
  list_attr :disease_array


end