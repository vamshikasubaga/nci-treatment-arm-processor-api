class DiseasePieData
  include Aws::Record

  set_table_name "ta_disease_pie_data_dev"


  string_attr :id, hash_key: true
  list_attr :disease_array


end