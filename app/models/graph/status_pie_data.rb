class StatusPieData
  include Aws::Record

  set_table_name "ta_status_pie_data_dev"

  string_attr :id, hash_key: true
  list_attr :status_array


end